# Domain Profile

<!--
HOW TO USE: Fill this in manually OR let /discover (interactive interview) generate it.
All agents read this file to calibrate their field-specific behavior.
Delete sections that don't apply. Add sections specific to your field.
If no field is specified, agents default to applied economics.
-->

## Field

**Primary:** [e.g., Health Economics, Labor Economics, Development, IO, Public Finance]
**Adjacent subfields:** [e.g., Labor, Public, IO — fields whose methods and journals overlap]

---

## Target Journals (ranked by tier)

<!-- The Orchestrator uses this for journal selection. The Librarian prioritizes these in searches. -->

| Tier | Journals |
|------|----------|
| Top-5 | AER, Econometrica, JPE, QJE, REStud |
| Top field | [e.g., JHE, RAND JE, AEJ:EP, AEJ:Applied] |
| Strong field | [e.g., Health Affairs, AJHE, JPubE, JHR] |
| Specialty | [e.g., Medical Care, Health Services Research] |

---

## Common Data Sources

<!-- The Explorer prioritizes these. The explorer-critic knows their quirks. -->

| Dataset | Type | Access | Notes |
|---------|------|--------|-------|
| [e.g., CPS] | [survey/admin/panel] | [public/restricted] | [key strengths and limitations] |

---

## Common Identification Strategies

<!-- The Strategist considers these first. The strategist-critic knows field-specific threats. -->

| Strategy | Typical Application | Key Assumption to Defend |
|----------|-------------------|------------------------|
| [e.g., State-level DiD] | [Policy variation across states] | [Parallel trends in outcomes across treated/control states] |

---

## Field Conventions

<!-- The Coder and Writer follow these. The writer-critic checks for them. -->

- [e.g., Binary outcomes → report LPM alongside logit/probit marginal effects]
- [e.g., Cost outcomes → log transform or GLM (Gamma, log link)]
- [e.g., Clustering at state level for state-level policy variation]
- [e.g., Always discuss moral hazard / adverse selection implications]
- [e.g., Welfare analysis expected in top-5 submissions]

---

## Notation Conventions

<!-- The Writer and writer-critic enforce these. -->

| Symbol | Meaning | Anti-pattern |
|--------|---------|-------------|
| [e.g., $Y_{it}$] | [Outcome for individual i at time t] | [Don't use $y$ without subscripts] |

---

## Seminal References

<!-- The Librarian ensures these are cited when relevant. The strategist-critic knows their methods. -->

| Paper | Why It Matters |
|-------|---------------|
| [e.g., Finkelstein et al. (2012)] | [Oregon HIE — gold standard for insurance effects] |

---

## Theoretical Foundational References

<!-- The Theorist and theorist-critic default to these anchors when building or reviewing a theory section.
     Only needed if the paper has a formal theory section (econometric methods, theory+empirics,
     structural identification, or methodological reduced-form).
     Leave empty to fall back to the generic econometric theory defaults baked into the theorist agent. -->

| Topic | Anchor references |
|-------|------------------|
| [e.g., DiD with staggered adoption] | [e.g., Callaway & Sant'Anna (2021); Sant'Anna & Zhao (2020)] |
| [e.g., Semiparametric efficiency] | [e.g., Newey (1990, 1994); Bickel-Klaassen-Ritov-Wellner (1993)] |

---

## Paper Author Team

<!-- Used by the theorist-critic to calibrate respect. If the authors are themselves among the reference
     literature on a topic, the critic avoids lecturing them on their own contributions.
     List author surnames + the topics they are foundational on. -->

| Author | Foundational on |
|--------|----------------|
| [e.g., Callaway] | [DiD with staggered adoption, $ATT(g,t)$] |

---

## Field-Specific Referee Concerns

<!-- The domain-referee and methods-referee watch for these. -->

- [e.g., "Why not use the Oregon HIE?" — must address if studying insurance effects]
- [e.g., "Selection into treatment" — always a concern in health care utilization studies]
- [e.g., "Moral hazard vs adverse selection" — referees expect you to distinguish]
- [e.g., "External validity" — Medicaid population ≠ general population]

---

## Quality Tolerance Thresholds

<!-- Customize for your domain's standards. Used by quality.md. -->

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | [e.g., 1e-6] | [Numerical precision] |
| Standard errors | [e.g., 1e-4] | [MC variability] |
| Coverage rates | [e.g., ± 0.01] | [Simulation with B reps] |
