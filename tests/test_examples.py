import contextlib
import io
import json
import re
import sqlite3
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def slide_code(title):
    source = (ROOT / "ds2/ds2_web.tex").read_text()
    match = re.search(
        r"\\frametitle\{" + re.escape(title) + r"\}(.*?)\\end\{frame\}",
        source,
        re.DOTALL,
    )
    return "\n".join(
        re.findall(r"\\begin\{verbatim\}(.*?)\\end\{verbatim\}", match[1], re.DOTALL)
    )


class TeachingExamples(unittest.TestCase):
    def test_python_slides(self):
        namespace = {}
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            for title in (
                "Scraping one HTML page in Python",
                "Getting text from one pdf in Python",
                "Exception(al) Handling",
                "Find Things",
                "How?",
                "To Matrices",
            ):
                exec(compile(slide_code(title), title, "exec"), namespace)
        self.assertIn("If music be the food of love, play on.", output.getvalue())
        self.assertIn("Databases", namespace["content"])
        self.assertEqual(namespace["stems"], ["tax", "tax", "taxat", "taxabl", "incom"])
        self.assertEqual(namespace["counts"]["tax"], 2)
        self.assertEqual(namespace["text_bigrams"][0], ("taxing", "taxes"))
        self.assertIn("https://example.com/", output.getvalue())

    def test_missing_pdf_handling(self):
        from pypdf import PdfReader

        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            exec(
                slide_code("Exception(al) Handling"),
                {"PdfReader": PdfReader, "pdf_path": ROOT / "does-not-exist.pdf"},
            )
        self.assertIn("Cannot open", output.getvalue())

    def test_json_slide(self):
        source = (ROOT / "ds3/ds3_web.tex").read_text()
        frame = source.split(r"\frametitle{JSON}", 1)[1].split(r"\end{frame}", 1)[0]
        code = re.search(
            r"\\begin\{verbatim\}(.*?)\\end\{verbatim\}", frame, re.DOTALL
        )[1]
        data = json.loads(code)
        self.assertIs(data["active"], True)
        self.assertIsNone(data["address"])
        self.assertEqual(data["members"], 42)

    def test_xml_slide(self):
        source = (ROOT / "ds3/ds3_web.tex").read_text()
        frame = source.split(r"\frametitle{XML}")[-1].split(r"\end{frame}", 1)[0]
        code = re.search(
            r"\\begin\{verbatim\}(.*?)\\end\{verbatim\}", frame, re.DOTALL
        )[1]
        document = ET.fromstring(code)
        self.assertEqual(document.tag, "DOC")
        self.assertEqual(document.findtext("DATE"), "2006-06-05")

    def test_regex_boundaries_and_repetition(self):
        self.assertEqual(re.findall(r"\b[tT]he\b", "The theme is the"), ["The", "the"])
        self.assertEqual(re.findall(r"[a-e1-9]", "az05Z"), ["a", "5"])
        self.assertIsNone(re.fullmatch(r".", "\n"))
        for text in ("", "abc", "a\nb"):
            self.assertEqual(re.findall(r".{0,}", text), re.findall(r".*", text))

    def test_sql_joins_and_set_operations(self):
        with sqlite3.connect(":memory:") as db:
            db.executescript("""
                CREATE TABLE R1 (A INTEGER, label TEXT);
                CREATE TABLE R2 (A INTEGER, label TEXT);
                INSERT INTO R1 VALUES (1, 'x'), (2, 'y'), (3, 'z');
                INSERT INTO R2 VALUES (1, 'x'), (2, 'different'), (4, 'w');
                """)
            self.assertEqual(
                len(db.execute("SELECT * FROM R1 CROSS JOIN R2").fetchall()), 9
            )
            equijoin = db.execute("SELECT * FROM R1 JOIN R2 ON R1.A = R2.A").fetchall()
            natural = db.execute("SELECT * FROM R1 NATURAL JOIN R2").fetchall()
            self.assertEqual(len(equijoin), 2)
            self.assertEqual(natural, [(1, "x")])
            left = db.execute("SELECT * FROM R1 LEFT JOIN R2 ON R1.A = R2.A").fetchall()
            self.assertEqual(left[-1], (3, "z", None, None))
            self.assertEqual(
                db.execute(
                    "SELECT A FROM R1 INTERSECT SELECT A FROM R2 ORDER BY A"
                ).fetchall(),
                [(1,), (2,)],
            )
            self.assertEqual(
                len(db.execute("SELECT A FROM R1 UNION SELECT A FROM R2").fetchall()), 4
            )
            self.assertEqual(
                len(
                    db.execute("SELECT A FROM R1 UNION ALL SELECT A FROM R2").fetchall()
                ),
                6,
            )
            self.assertEqual(
                db.execute("SELECT A FROM R1 EXCEPT SELECT A FROM R2").fetchall(),
                [(3,)],
            )
            db.execute("CREATE VIEW V AS SELECT * FROM R1")
            with self.assertRaises(sqlite3.OperationalError):
                db.execute("UPDATE V SET A = 7")
            db.execute("UPDATE R1 SET A = 7 WHERE A = 3")
            self.assertEqual(
                db.execute("SELECT A FROM V WHERE label = 'z'").fetchone(), (7,)
            )

    def test_pagerank_with_dangling_node(self):
        alpha = 0.85
        ranks = [0.5, 0.5]
        for _ in range(100):
            a, b = ranks
            ranks = [
                (1 - alpha) / 2 + alpha * b / 2,
                (1 - alpha) / 2 + alpha * (a + b / 2),
            ]
        self.assertAlmostEqual(sum(ranks), 1)
        self.assertAlmostEqual(ranks[0], 1 / (2 + alpha))
        self.assertAlmostEqual(ranks[1], (1 + alpha) / (2 + alpha))


if __name__ == "__main__":
    unittest.main()
