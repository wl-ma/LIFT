# Translator contract: natural-units-v1

Return only the request's natural-language Schema, keyed by program-assigned slots.
Preserve quantified objects, hypotheses, formulas, conclusions and defining formulas.
Names, types, modules, dependencies and metadata are program-owned and must not appear
as additional response fields. Use only supplied compiler context. Record unresolved
ambiguity in uncertainties. For repairs return exactly the allowed slots, replacing
whole natural-language records. Executable prompts live in natural_contracts.py.
