# Project Vela — Fintech User Behavior Analysis

> **North Star Question:** What drives high-value user behavior on a B2B fintech platform — and who's at risk of disengaging before they do?

Vela is a fictional B2B fintech payment platform. This project analyzes user behavior, feature adoption, transaction patterns, and churn signals across 81,000+ rows of synthetic but realistic data — built to answer questions a real fintech growth or retention team would actually care about.

---

## The Story in Two Parts

**Part 1 — What drives high-value user behavior?**
SQL analysis across five business tracks → Power BI dashboard

**Part 2 — Who's at risk of disengaging?**
Churn-focused Python EDA → Feature engineering → ML churn prediction model

---

## Dataset

| Table | Rows | Description |
|---|---|---|
| `users` | 2,000 | Users with KYC status and segment (casual / regular / power_user) |
| `payment_features` | 15 | Feature catalog — each gated by KYC level |
| `merchants` | 200 | Businesses receiving payments through Vela |
| `feature_activations` | 6,951 | Bridge table — which users activated which features |
| `transactions` | 70,109 | Core fact table — every payment event |
| `kyc_history` | 1,869 | KYC status change audit trail |
| **Total** | **81,144** | |

85% transaction completion rate. Feature adoption ladder confirmed across all three user segments — power users average 7.4 features activated vs 1.5 for casual users, with proportional gaps in transaction volume and value.

---

## Part 1 — SQL Analysis

### Business Questions

1. Does activating more payment features predict higher transaction volume and value?
2. What does a healthy transaction profile look like — and what does a risky one look like?
3. Which users are showing early behavioral signs of churn?
4. How does KYC verification level affect feature access and transaction behavior?

### SQL Tracks

| Track | File | Business Question | Status |
|---|---|---|---|
| A | `01_feature_adoption.sql` | Does feature adoption predict transaction value? | ✅ Done |
| B | `02_transaction_behavior.sql` | What does a healthy vs. risky transaction profile look like? | ✅ Done |
| C | `03_churn_signals.sql` | Which users are trending toward disengagement? | ✅ Done |
| D | `04_kyc_progression.sql` | How does KYC level affect feature access and revenue? | 🔄 In Progress |
| — | `05_north_star_answer.sql` | Synthesis: what actually drives high-value behavior? | 🔒 Next |

### Key Findings

**Track A — Feature Adoption**
- Feature adoption is the clearest predictor of transaction value: power users (avg 7.4 features) generate 6× more transactions and 12× more total value than casual users (avg 1.5 features).
- The adoption-to-value ladder is consistent across all three segments with no crossover — making feature activation a reliable growth and monetization lever.
- Low-adoption users within higher segments represent a retention risk, flagged for deeper investigation in Track C.

**Track B — Transaction Behavior**
- Government merchants drive the highest transaction volume and value across all segments — but not the highest success rate. For regular users, utilities leads; for power users, it's healthcare.
- Non-merchant transactions (peer-to-peer, insurance, etc.) outperform merchant transactions in both volume and value by a significant margin.
- Power user revenue concentration is structural, not outlier-driven — high per-transaction value holds consistently across all merchant categories.

**Track C — Churn Signals**
- Feature activation count is *not* a reliable churn signal — churned and active users show near-identical average feature counts (4.06 vs 3.74), invalidating the initial hypothesis.
- Transaction frequency is the primary signal: churned users average 10.9 transactions vs 39.8 for active users. Low-frequency users (≤10 transactions) churn at 33.6% vs 4.2% for high-frequency users.
- Churn rate is flat across all user segments (~8–9%) — no single tier is disproportionately at risk. Re-engagement efforts should focus on driving transaction frequency across all segments, not targeting a specific tier.

---

## Stack

### Part 1
| Tool | Use |
|---|---|
| MySQL | Schema design, seed data, SQL analysis |
| Power BI Desktop | Direct MySQL connection → DAX measures → interactive dashboard (`.pbix`) |
| GitHub | Version control and portfolio publishing |

### Part 2
| Tool | Use |
|---|---|
| Python 3 + pandas | Churn-focused EDA — distributions, correlations, feature candidates |
| matplotlib / seaborn | Visualization of EDA findings |
| scikit-learn | Feature engineering + churn prediction model |

---

## Project Status

| Phase | Focus | Status |
|---|---|---|
| P1.1 — Foundation | Schema design, seed data, validation | ✅ Done |
| P1.2 — SQL Analysis | 5 tracks — each answers a distinct business question | 🔄 In Progress |
| P1.3 — Power BI Dashboard | Direct MySQL connection → interactive dashboard | 🔒 Next |
| P1.4 — Documentation | North star synthesis + `PHASE1_FINDINGS.md` | ⬜ Upcoming |
| P2.1–2.4 — Python + ML | Churn EDA, feature engineering, model, docs | 🔒 Locked |

---

## Repo Structure

```
project-vela/
├── sql/
│   ├── 01_feature_adoption.sql
│   ├── 02_transaction_behavior.sql
│   ├── 03_churn_signals.sql
│   ├── 04_kyc_progression.sql      ← in progress
│   └── 05_north_star_answer.sql    ← upcoming
├── fintech_analytics_seed.sql
└── README.md
```