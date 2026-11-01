import json
import math
import subprocess
import sys
import time
import unittest
from unittest.mock import patch

import runner


class MeasurementBudgetTests(unittest.TestCase):
    def measure(self, duration, budget=300, runs=10):
        clock = [0.0]
        commands = []

        def rss(executable, deadline, env):
            clock[0] += duration
            return {"peak_rss_kb": 2048, "times": [duration], "user": duration, "system": 0, "exit_codes": [0]}

        def run(command, deadline, env):
            commands.append(command)
            clock[0] += duration
            if "--export-json" in command:
                path = command[command.index("--export-json") + 1]
                sample = len([cmd for cmd in commands if "--export-json" in cmd])
                with open(path, "w", encoding="utf-8") as stream:
                    json.dump({"results": [{
                        "times": [duration + sample - 1],
                        "user": duration,
                        "system": 0,
                        "exit_codes": [0],
                    }]}, stream)

        with patch.dict(runner.CONFIG, {
            "case-time-budget-seconds": budget, "runs": runs, "warmup-runs": 5,
        }), patch("runner.time.monotonic", side_effect=lambda: clock[0]), patch(
            "runner._measure_rss_sample", side_effect=rss
        ), patch("runner._run_until", side_effect=run):
            return runner.measure_executable("program"), commands

    def test_slow_case_keeps_completed_points_and_reduces_warmups(self):
        result, _ = self.measure(80)
        self.assertTrue(result["budget_limited"])
        self.assertEqual(result["measurement_seconds"], 240)
        self.assertEqual(result["warmup_runs"], 1)
        self.assertEqual(result["sample_count"], 2)
        self.assertEqual(result["peak_rss_kb"], 2048)
        self.assertEqual(result["results"][0]["times"], [80, 81])
        self.assertAlmostEqual(result["results"][0]["stddev"], math.sqrt(0.5))

    def test_one_completed_point_has_no_standard_deviation(self):
        result, _ = self.measure(120)
        self.assertEqual(result["sample_count"], 1)
        self.assertIsNone(result["results"][0]["stddev"])

    def test_long_rss_run_supplies_labeled_timing_when_no_more_points_fit(self):
        result, commands = self.measure(200)
        self.assertEqual(commands, [])
        self.assertTrue(result["budget_limited"])
        self.assertEqual(result["timing_source"], "gnu-time")
        self.assertEqual(result["sample_count"], 1)
        self.assertEqual(result["results"][0]["mean"], 200)
        self.assertIsNone(result["results"][0]["stddev"])

    def test_fast_case_keeps_requested_samples_and_warmups(self):
        result, _ = self.measure(1)
        self.assertFalse(result["budget_limited"])
        self.assertEqual(result["sample_count"], 10)
        self.assertEqual(result["warmup_runs"], 5)
        self.assertEqual(result["measurement_seconds"], 15)

    def test_incomplete_rss_run_does_not_report_a_footprint(self):
        with patch("runner._measure_rss_sample", side_effect=subprocess.TimeoutExpired("time", 1)):
            result = runner.measure_executable("program")
        self.assertTrue(result["budget_limited"])
        self.assertEqual(result["results"], [])
        self.assertNotIn("peak_rss_kb", result)

    def test_deadline_stops_a_running_sample(self):
        start = time.monotonic()
        with self.assertRaises(subprocess.TimeoutExpired):
            runner._run_until([sys.executable, "-c", "import time; time.sleep(5)"], start + 0.05, None)
        self.assertLess(time.monotonic() - start, 1)


if __name__ == "__main__":
    unittest.main()
