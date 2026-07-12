"""Live, dependency-free terminal dashboard for benchmark results."""

import os
import shutil
import sys


_ALT_SCREEN_ON = "\x1b[?1049h"
_ALT_SCREEN_OFF = "\x1b[?1049l"
_CLEAR_SCREEN = "\x1b[2J\x1b[H"
_HIDE_CURSOR = "\x1b[?25l"
_SHOW_CURSOR = "\x1b[?25h"


def _safe_float(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def _first_result_entry(payload):
    if not isinstance(payload, dict):
        return None
    entries = payload.get("results")
    if not isinstance(entries, list) or not entries:
        return None
    entry = entries[0]
    return entry if isinstance(entry, dict) else None


def _timing_seconds(payload):
    entry = _first_result_entry(payload)
    return _safe_float(entry.get("mean")) if entry else None


def _peak_rss_kb(payload):
    if not isinstance(payload, dict):
        return None
    for key in ("peak_rss_kb", "max_rss_kb", "peak_rss", "max_rss"):
        value = _safe_float(payload.get(key))
        if value is not None:
            return value
    entry = _first_result_entry(payload)
    if entry:
        for key in ("peak_rss_kb", "max_rss_kb", "peak_rss", "max_rss"):
            value = _safe_float(entry.get(key))
            if value is not None:
                return value
    return None


def _format_duration(seconds):
    if seconds < 1e-6:
        return f"{seconds * 1e9:.2f} ns"
    if seconds < 1e-3:
        return f"{seconds * 1e6:.2f} us"
    if seconds < 1:
        return f"{seconds * 1e3:.2f} ms"
    if seconds < 60:
        return f"{seconds:.3f} s"
    return f"{seconds / 60:.2f} min"


def _format_rss(kibibytes):
    if kibibytes < 1024:
        return f"{kibibytes:.0f} KiB"
    mebibytes = kibibytes / 1024
    if mebibytes < 1024:
        return f"{mebibytes:.1f} MiB"
    return f"{mebibytes / 1024:.2f} GiB"


def _ellipsize(text, width):
    if width <= 0:
        return ""
    if len(text) <= width:
        return text
    if width == 1:
        return "…"
    return text[: width - 1] + "…"


def _metric_panel(title, rows, width, formatter):
    """Render a horizontal bar panel with a scale derived from current rows."""

    width = max(24, width)
    if not rows:
        return [_ellipsize(title, width), "waiting for data…"]

    rows = sorted(rows)
    maximum = max(value for _, value in rows)
    best = min(value for _, value in rows)
    value_text = {label: formatter(value) for label, value in rows}
    value_width = min(max(len(value) for value in value_text.values()), 12)
    label_width = min(max(max(len(label) for label, _ in rows), 8), 22)
    bar_width = max(3, width - label_width - value_width - 4)

    lines = [
        _ellipsize(f"{title} · auto 0–{formatter(maximum)}", width),
        "─" * width,
    ]
    for label, value in rows:
        ratio = 0 if maximum <= 0 else value / maximum
        filled = 0 if value <= 0 else max(1, round(ratio * bar_width))
        bar = "█" * filled
        marker = "◆" if value == best else " "
        lines.append(
            f"{_ellipsize(label, label_width):<{label_width}} "
            f"{bar:<{bar_width}} "
            f"{value_text[label]:>{value_width}} {marker}"
        )
    return lines


def _side_by_side(left, right, panel_width):
    rows = max(len(left), len(right))
    lines = []
    for index in range(rows):
        lhs = left[index] if index < len(left) else ""
        rhs = right[index] if index < len(right) else ""
        lines.append(f"{lhs:<{panel_width}} │ {rhs}")
    return lines


def render_dashboard(
    results,
    *,
    current_bench,
    current_variant,
    completed,
    total,
    bench_total,
    status,
    width,
    height,
):
    """Build one dashboard frame; every call recomputes both chart scales."""

    width = max(40, width)
    height = max(10, height)
    fraction = 0 if total == 0 else completed / total
    progress_width = min(28, max(10, width - 52))
    progress_filled = round(fraction * progress_width)
    progress = "█" * progress_filled + "░" * (progress_width - progress_filled)
    target = f"{current_bench}/{current_variant}" if current_bench else "—"

    lines = [
        _ellipsize("Reussir benchmark dashboard", width),
        _ellipsize(
            f"[{progress}] {completed}/{total} ({fraction * 100:5.1f}%) · "
            f"{status} {target}",
            width,
        ),
    ]

    bench_results = results.get(current_bench, {}) if current_bench else {}
    lines.append(
        _ellipsize(
            f"Current benchmark: {current_bench or '—'} · "
            f"{len(bench_results)}/{bench_total} variants complete",
            width,
        )
    )
    lines.append("")

    timing_rows = []
    rss_rows = []
    for variant, payload in bench_results.items():
        timing = _timing_seconds(payload)
        if timing is not None:
            timing_rows.append((variant, timing))
        rss = _peak_rss_kb(payload)
        if rss is not None:
            rss_rows.append((variant, rss))

    if width >= 72:
        panel_width = (width - 3) // 2
        timing_panel = _metric_panel(
            "Mean runtime ↓",
            timing_rows,
            panel_width,
            _format_duration,
        )
        rss_panel = _metric_panel(
            "Peak RSS ↓",
            rss_rows,
            panel_width,
            _format_rss,
        )
        lines.extend(_side_by_side(timing_panel, rss_panel, panel_width))
    else:
        timing_panel = _metric_panel(
            "Mean runtime ↓", timing_rows, width, _format_duration
        )
        lines.extend(timing_panel)
        remaining = height - len(lines) - 2
        if remaining >= 4:
            lines.append("")
            rss_panel = _metric_panel(
                "Peak RSS ↓", rss_rows, width, _format_rss
            )
            lines.extend(rss_panel[:remaining])

    lines.append("")
    lines.append(_ellipsize("◆ current best · charts rescale after every result", width))
    return "\n".join(lines[:height])


class LiveBenchmarkDashboard:
    """Alternate-screen renderer that restores the terminal on every exit path."""

    def __init__(self, enabled=None, stream=None):
        self.stream = stream or sys.stderr
        if enabled is None:
            is_tty = bool(getattr(self.stream, "isatty", lambda: False)())
            enabled = is_tty and os.environ.get("TERM") != "dumb"
        self.enabled = enabled
        self._active = False

    def __enter__(self):
        if self.enabled:
            self.stream.write(_ALT_SCREEN_ON + _HIDE_CURSOR + _CLEAR_SCREEN)
            self.stream.flush()
            self._active = True
        return self

    def update(self, **frame):
        if not self.enabled:
            return
        size = shutil.get_terminal_size((100, 30))
        rendered = render_dashboard(
            **frame,
            width=size.columns,
            height=max(10, size.lines - 1),
        )
        self.stream.write(_CLEAR_SCREEN + rendered)
        self.stream.flush()

    def __exit__(self, exc_type, exc_value, traceback):
        if self._active:
            self.stream.write(_SHOW_CURSOR + _ALT_SCREEN_OFF)
            self.stream.flush()
            self._active = False
        return False
