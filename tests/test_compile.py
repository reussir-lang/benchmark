import pathlib
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

import compile as compilers
import runner
from config import positive_seconds


class CompilationDeadlineTests(unittest.TestCase):
    def test_timeout_stops_children_that_keep_output_pipes_open(self):
        with tempfile.TemporaryDirectory() as directory:
            marker = pathlib.Path(directory) / "child-survived"
            child = (
                "import pathlib,time; time.sleep(0.5); "
                f"pathlib.Path({str(marker)!r}).touch()"
            )
            parent = (
                "import subprocess,sys; "
                f"subprocess.Popen([sys.executable, '-c', {child!r}])"
            )

            def build(*args):
                compilers._run_quiet(
                    [sys.executable, "-c", parent], directory, "test compiler"
                )

            with patch.dict(compilers.CONFIG, {"compile-timeout-seconds": 0.2}):
                with patch.object(compilers, "_compile_cell", side_effect=build):
                    with self.assertRaises(compilers.CompilationTimeout):
                        compilers.compile_cell({}, {}, None, None, None)
            time.sleep(0.6)
            self.assertFalse(marker.exists(), "compiler child survived the timeout")

    def test_later_build_stage_does_not_get_a_fresh_budget(self):
        def build(*args):
            compilers._run_quiet([sys.executable, "-c", "pass"], None, "compile")
            compilers._run_quiet([sys.executable, "-c", "pass"], None, "link")

        with patch.dict(compilers.CONFIG, {"compile-timeout-seconds": 1}):
            with patch.object(compilers, "_compile_cell", side_effect=build):
                with patch("compile.time.monotonic", side_effect=[100, 100, 102]):
                    with self.assertRaisesRegex(compilers.CompilationTimeout, "link"):
                        compilers.compile_cell({}, {}, None, None, None)

    def test_runner_records_timeout_without_measuring(self):
        with patch.object(
            compilers, "compile_cell",
            side_effect=compilers.CompilationTimeout("morphic compilation", 2),
        ), patch.object(runner, "measure_executable") as measure:
            result = runner.run_benchmark("derive", "morphic")
        self.assertEqual(result["status"], "compile_timeout")
        self.assertEqual(result["compile_timeout_seconds"], 2)
        self.assertEqual(result["results"], [])
        self.assertNotIn("peak_rss_kb", result)
        measure.assert_not_called()

    def test_invalid_limits_are_rejected(self):
        for value in [0, -1, "nan", "inf", "-inf"]:
            with self.subTest(value=value), self.assertRaises(ValueError):
                positive_seconds(value)


if __name__ == "__main__":
    unittest.main()
