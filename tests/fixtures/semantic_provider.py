"""Deterministic protocol test double; never use as a semantic quality evaluator."""

import hashlib
import json
import sys


def digest(value):
    return hashlib.sha256(
        json.dumps(
            value, sort_keys=True, separators=(",", ":"), ensure_ascii=False
        ).encode()
    ).hexdigest()


def main():
    request = json.load(sys.stdin)
    if request["target"]["name"] != "LIFTExample.twice_eq":
        raise ValueError("This test double supports only the named fixture theorem")
    if request["role"] == "translator":
        correct = bool(request.get("previous_review"))
        result = {
            "statement": "For every natural number n, twice(n) equals n + n."
            if correct
            else "For every natural number n, twice(n) equals n.",
            "objects": ["n is a natural number"],
            "assumptions": [],
            "quantifiers": ["for every natural number n"],
            "definition": "",
            "uncertainties": [],
        }
    else:
        passed = "n + n" in request["draft"]["statement"]
        evidence = {
            "declaration_key": request["target"]["declaration_key"],
            "field": "type",
            "excerpt": request["target"]["type"],
        }
        result = {
            "draft_hash": request["draft_hash"],
            "context_hash": request["context_hash"],
            "status": "passed" if passed else "rejected",
            "checks": {
                key: {
                    "verdict": "passed" if passed else "failed",
                    "reason": "The fixture equation has n + n on its right hand side.",
                    "evidence": evidence,
                }
                for key in request["checks"]
            },
            "issues": []
            if passed
            else [
                {
                    "category": "wrong_formula",
                    "message": "Restore n + n in the conclusion.",
                    "evidence": evidence,
                }
            ],
            "context_requests": [],
        }
    print(
        json.dumps(
            {
                "response": result,
                "model": "deterministic-test-double",
                "usage": {"total_tokens": 0},
                "not_a_language_model": True,
            }
        )
    )


if __name__ == "__main__":
    main()
