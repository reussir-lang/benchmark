import unittest

from terminal_dashboard import render_dashboard


def payload(mean, rss):
    return {
        "results": [{"mean": mean}],
        "peak_rss_kb": rss,
    }


def runtime_bar_width(frame, variant):
    line = next(line for line in frame.splitlines() if line.startswith(variant))
    runtime_panel = line.split("│", 1)[0]
    return runtime_panel.count("█")


class TerminalDashboardTests(unittest.TestCase):
    def render(self, results, completed):
        return render_dashboard(
            results,
            current_bench="derive",
            current_variant="lean",
            completed=completed,
            total=9,
            bench_total=9,
            status="Running",
            width=100,
            height=24,
        )

    def test_bar_scale_is_recomputed_when_a_larger_value_arrives(self):
        first = self.render({"derive": {"rust": payload(1.0, 1024)}}, 1)
        second = self.render(
            {
                "derive": {
                    "rust": payload(1.0, 1024),
                    "lean": payload(2.0, 2048),
                }
            },
            2,
        )

        self.assertGreater(
            runtime_bar_width(first, "rust"), runtime_bar_width(second, "rust")
        )
        self.assertIn("auto 0–2.000 s", second)

    def test_frame_contains_progress_runtime_and_memory(self):
        frame = self.render({"derive": {"rust": payload(0.125, 1536)}}, 1)

        self.assertIn("1/9", frame)
        self.assertIn("derive/lean", frame)
        self.assertIn("125.00 ms", frame)
        self.assertIn("1.5 MiB", frame)
        self.assertIn("◆ current best", frame)

    def test_empty_benchmark_renders_a_waiting_state(self):
        frame = self.render({}, 0)
        self.assertIn("0/9 variants complete", frame)
        self.assertIn("waiting for data", frame)


if __name__ == "__main__":
    unittest.main()
