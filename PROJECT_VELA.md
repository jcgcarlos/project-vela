# Project Vela — Roadmap & Progress Tracker

## North Star
"What drives high-value user behavior on Vela — 
and who's at risk of disengaging?"

---

## Phase 1: SQL Analysis
### User Segmentation
- [ ] Transaction volume by user segment
- [ ] Average transaction value by segment
- [ ] Top 10% users — what do they have in common?

### Feature Adoption
- [ ] Feature activation count per user
- [ ] Which features correlate with higher transaction value?
- [ ] KYC completion funnel

### Disengagement Signals
- [ ] Users active 30 days ago but not in last 7 days
- [ ] Segments with declining transaction frequency

---

## Phase 2: Python EDA
*(Unlocks when Phase 1 is 80% complete)*
- [ ] Load Vela data into pandas
- [ ] Distribution analysis — transactions, segments, features
- [ ] Correlation between feature count and transaction value
- [ ] Visualizations — ready for portfolio

---

## Phase 3: ML Churn Model
*(Unlocks when Phase 2 is complete)*
- [ ] Define churn (no transaction in X days)
- [ ] Feature engineering
- [ ] Train classification model
- [ ] Evaluate + interpret results

---

## Graduated Queries Log
| Date | File | Business Question Answered |
|------|------|---------------------------|
| | | |