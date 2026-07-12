import io
import unittest
from contextlib import redirect_stderr
from unittest.mock import patch

from main import run_targets


def payload(mean, rss):
    return {
        "results": [{"mean": mean}],
        "peak_rss_kb": rss,
    }


class MainTuiIntegrationTests(unittest.TestCase):
    def test_live_loop_accumulates_and_redraws_each_result(self):
        targets = [("derive", "rust"), ("derive", "lean")]
        samples = [payload(0.1, 1024), payload(0.2, 2048)]

        terminal = io.StringIO()
        with patch("main.run_benchmark", side_effect=samples) as benchmark:
            with redirect_stderr(terminal):
                results = run_targets(targets, tui_choice=True)

        self.assertEqual(results["derive"], {"rust": samples[0], "lean": samples[1]})
        self.assertEqual(benchmark.call_count, 2)
        output = terminal.getvalue()
        self.assertEqual(output.count("\x1b[2J\x1b[H"), 5)
        self.assertIn("\x1b[?1049h", output)
        self.assertIn("\x1b[?1049l", output)


if __name__ == "__main__":
    unittest.main()
