---
name: strategize
description: Design identification strategy, pre-analysis plan, or formal theory section. Dispatches Strategist / Theorist (proposer) and the paired critic (validator). Replaces /identify and /pre-analysis-plan.
argument-hint: "[mode: strategy | pap | pap interactive | theory] [research question or spec path]"
allowed-tools: Read,Grep,Glob,Write,Task
---

# Strategize

Design an identification strategy, pre-analysis plan, or formal theory section by dispatching the appropriate creator (**Strategist** or **Theorist**) and its paired critic.

**Input:** `$ARGUMENTS` — mode keyword followed by research question or path to research spec.

---

## Modes

### `/strategize [question]` or `/strategize strategy [question]` — Identification Strategy
Design the causal identification strategy.

**Agents:** Strategist → strategist-critic
**Output:** Strategy memo + robustness plan + falsification tests

Workflow:
1. **Pre-Strategy Report (mandatory).** Before proposing any strategy, the Strategist must output a structured report proving it read the discovery inputs:

```markdown
## Pre-Strategy Report
**Research spec:** [path or "not found"]
**Literature review:** [path or "not found"]
**Data assessment:** [path or "not found"]
**Domain profile:** [loaded / not found]

**Research question:** [one sentence from spec]
**Key findings from literature:**
- [What methods have been used for this question]
- [What gaps remain]
**Available data:**
- [Dataset name] — [key variables, coverage, access]
- [Variation available for identification]: [describe]
**Candidate designs from domain profile:** [list relevant designs]

Proceeding to strategy design.
```

If research spec, literature review, or data assessment are missing, the Strategist proceeds with ASSUMED placeholders — but flags each clearly.

2. Read .claude/references/domain-profile.md for common identification strategies in the field
3. Dispatch Strategist to produce:
   - Strategy memo: design choice, estimand, assumptions, comparison group
   - Pseudo-code: implementation sketch
   - Robustness plan: ordered list of checks with rationale
   - Falsification tests: what SHOULD NOT show effects
   - Referee objection anticipation: top 5 objections with responses
4. Dispatch strategist-critic to review through 4 phases:
   - Phase 1: Claim identification (design, estimand, treatment, control)
   - Phase 2: Core design validity (assumption checks, sanity checks)
   - Phase 3: Inference soundness (clustering, multiple testing)
   - Phase 4: Polish and completeness (robustness, citations)
5. If CRITICAL issues found, iterate (max 3 rounds per three-strikes)
6. Save memo to `quality_reports/strategy_memo_[topic].md`
7. Save review to `quality_reports/strategy_memo_[topic]_review.md`
8. **Save decision record** → `quality_reports/decisions/strategy_[topic].md`
   Using `templates/decision-record.md`, record:
   - **Decision:** The chosen identification strategy (design + estimator)
   - **Alternatives:** Other designs the Strategist considered (e.g., IV, RDD, SC, selection-on-observables)
   - **Why rejected:** For each, the specific reason (no valid instrument, insufficient density at cutoff, no clean donor pool, etc.)
   - **Key assumptions:** What must hold (parallel trends, exclusion restriction, continuity, etc.)
   - **What would invalidate:** What findings would force a strategy change (pre-trends failure, weak first stage, manipulation at cutoff)

### `/strategize pap [spec]` — Pre-Analysis Plan
Draft a pre-analysis plan following AEA/OSF/EGAP standards.

**Input:** `$ARGUMENTS` — path to research spec file, a topic, or `interactive` for guided interview.

- If `$ARGUMENTS` includes a file path: read it (research spec from `/discover interview`)
- If `$ARGUMENTS` includes `interactive`: conduct the guided PAP interview (see below)
- Otherwise: treat as topic and draft with ASSUMED placeholders marked clearly

**Agents:** Strategist (in PAP mode), optionally strategist-critic
**Output:** Pre-analysis plan document

#### Interactive PAP Interview (6-Question Guided Flow)

When invoked as `/strategize pap interactive`, ask these questions one at a time before drafting:

1. **What is the research question?**
2. **What is the study design?** (RCT / natural experiment / quasi-experimental / observational)
3. **What are the primary outcome variables?** (names, measurement, data source)
4. **What is the identification strategy?** (randomization mechanism / treatment assignment / source of variation)
5. **What subgroup analyses are pre-specified?** (with justification for each)
6. **What multiple testing concerns exist?** (number of primary outcomes, family-wise error rate plan)

After all 6 answers are collected, proceed to PAP drafting.

#### PAP Sections

Dispatch Strategist in PAP mode to produce all standard sections:

1. **Study overview** — research question, design, treatment, control
2. **Outcomes** — primary, secondary, mechanism variables with measurement details
3. **Estimating equations** — with full notation protocol
4. **Subgroup analyses** — pre-specified, with justification for each
5. **Multiple testing correction** — Bonferroni / Benjamini-Hochberg / Romano-Wolf (specify which and why)
6. **Power calculations** — MDE, baseline statistics, sample size, assumptions stated explicitly with sensitivity
7. **Sample and exclusion rules** — inclusion criteria, attrition handling, outlier treatment
8. **Data and analysis** — sources, software, randomization/assignment mechanism
9. **Timeline** — data collection, analysis, registration dates
10. **Deviations log** — empty template for tracking post-registration changes

#### Platform-Specific PAP Templates

Ask the user which registry platform they plan to use (if unclear from context):

**AEA RCT Registry:**
- Most structured format. All fields required.
- Must be registered before intervention begins.
- Strict section ordering: hypotheses → outcomes → analysis → power.
- Requires IRB information and funding sources.

**OSF (Open Science Framework):**
- More flexible format. Good for observational studies and natural experiments.
- Allows iterative updates with version history.
- Less rigid section structure — can adapt to study design.
- Supports pre-registration of observational/archival studies.

**EGAP (Evidence in Governance and Politics):**
- Development economics and political science focused.
- Additional governance and ethics questions required.
- Emphasizes pre-specification of heterogeneous treatment effects.
- Requires description of implementing partners and field conditions.

#### Observational Study PAP Adaptation

For observational, quasi-experimental, or natural experiment designs, adapt the PAP template:

- **Identification strategy replaces randomization** — describe the source of exogenous variation
- **Comparison group replaces control group** — define who is compared to whom and why
- **Identification assumption discussion** — explicitly state and defend each assumption
- **Placebo and falsification tests** — pre-specify what SHOULD NOT show effects
- **Robustness to specification choices** — pre-commit to bandwidth, functional form, sample restrictions
- **Treatment of endogeneity concerns** — document known threats and planned diagnostics

#### ASSUMED Placeholder Safety

**CRITICAL: Flag every ASSUMED item clearly. The researcher must review and approve before registration.**

When drafting a PAP from a topic (without a full research spec or interactive interview), many details will be assumed. For each assumed item:

- Mark it with `[ASSUMED]` in bold
- Explain what was assumed and why
- Provide the most reasonable default but flag it for review

A registered PAP with unchecked assumptions is worse than no PAP. The final section of every PAP must include:

```markdown
## Pre-Registration Checklist

**Review every [ASSUMED] item before registering this plan.**

- [ ] [ASSUMED] Item 1 — [what was assumed]
- [ ] [ASSUMED] Item 2 — [what was assumed]

**Do not register until all items are reviewed and confirmed or corrected.**
```

#### Optional strategist-critic Review

After PAP creation, optionally dispatch the strategist-critic to review:
- Are identification assumptions clearly stated and defensible?
- Is the estimator choice appropriate for the design?
- Are power calculation assumptions reasonable? Show sensitivity.
- Are pre-specified subgroups justified (not fishing)?
- Are multiple testing corrections appropriate?
- Are any [ASSUMED] items potentially problematic if left uncorrected?

Save review to `quality_reports/pre_analysis_plan_[topic]_review.md`

Save PAP to `quality_reports/pre_analysis_plan_[topic].md`

---

### `/strategize theory [target]` — Formal Theory Section

Produce a formal theory section: assumptions, definitions, lemmas, theorems, and proofs.

**When to use:**
- Paper type is **econometric methods** (the method is the contribution)
- Paper type is **theory + empirics** (theoretical predictions are tested)
- Paper type is **structural** (identification of structural parameters needs formal argument)
- Paper type is **methodological reduced-form** (the design contributes a new estimator)

**Skip this mode** for applied papers that use off-the-shelf estimators — the strategist's memo is sufficient.

**Input:** `$ARGUMENTS` — research question, path to strategy memo, or path to existing paper/draft.

**Agents:** Theorist → theorist-critic
**Output:** Theory memo + assumptions.tex + results.tex + proofs.tex + notation glossary

Workflow:
1. **Pre-Theory Report (mandatory).** Before writing any math, the Theorist must output a structured report showing what was read:

```markdown
## Pre-Theory Report
**Research spec:** [path or "not found"]
**Strategy memo:** [path or "not found"]
**Existing paper/draft:** [path or "not found"]
**Domain profile:** [loaded / not found]
**Notation conventions:** [header.tex path / domain-profile notation table / "not found"]
**Bibliography base:** [path / "not found"]

**Paper type:** [econometric methods / theory+empirics / structural / methodological reduced-form]
**Theoretical object(s) to produce:** [identification / consistency / asymp. normality / influence function / DML / bootstrap / test / proposition]
**Data structure:** [iid / panel / staggered / clustered / triangular array]
**Target parameter:** [definition as functional of P]
**Estimator:** [definition]
**Assumptions anticipated:** [A1 sampling, A2 parallel trends, ...]

Proceeding to theory drafting.
```

If strategy memo or paper type is missing, the Theorist flags it and asks before proceeding.

2. Read `.claude/references/domain-profile.md` for the Theoretical Foundational References table and Author Team table.
3. Dispatch **Theorist** to produce:
   - `quality_reports/theory/[topic]/theory_memo.md`
   - `quality_reports/theory/[topic]/assumptions.tex`
   - `quality_reports/theory/[topic]/results.tex`
   - `quality_reports/theory/[topic]/proofs.tex`
   - `quality_reports/theory/[topic]/notation_glossary.md`
4. Dispatch **theorist-critic** to review through 4 sequential phases:
   - Phase 1: Claim identification (object type, target parameter, estimator, assumptions)
   - Phase 2: Proof validity (logical, measurability, expansions, identification, asymptotic distribution) — **early-stop on critical gaps**
   - Phase 3: Assumption minimality + statement calibration + notation consistency (INV-7)
   - Phase 4: Citation fidelity + linkage to empirical claims + exposition
5. If CRITICAL issues found, iterate (max 3 rounds per three-strikes). Escalation target: User.
6. Save review to `quality_reports/theory_[topic]_review.md`
7. **Save decision record** → `quality_reports/decisions/theory_[topic].md`
   Record:
   - **Decision:** The theoretical objects proved (identification, asymptotic distribution, etc.)
   - **Assumptions:** Full list with interpretation
   - **What's open:** What the theory does NOT cover (caveats for the writer)
   - **Linkage:** Which empirical claims each theorem supports

---

## Principles

- **Strategist proposes, strategist-critic critiques.** Adversarial pairing catches design flaws early.
- **Theorist proves, theorist-critic checks the proof.** Proof validity gates everything downstream — notation, citations, polish.
- **Strategy memo is the contract.** Once approved, the Coder implements it faithfully.
- **Catch problems before coding.** A flawed strategy caught now saves weeks of wasted analysis.
- **Multiple strategies are OK.** Present trade-offs and let the user choose.
- **The user decides.** If Strategist and strategist-critic disagree after 3 rounds, the user resolves it.
- **Pre-specification is the point.** Everything in a PAP is decided before seeing outcomes.
- **Be honest about what's exploratory.** Label subgroups and secondary outcomes clearly.
- **Power calculations require assumptions.** State every assumption. Show sensitivity.
- **A PAP is a commitment device.** Make sure the researcher understands what they're committing to.
