# Revenue Leakage & Growth Strategy Analysis (Olist)

End-to-end business analytics case study identifying revenue leakage, retention gaps, and operational risks in a large-scale e-commerce marketplace using SQL and Python.

---

## Business Context
Olist is a Brazilian e-commerce marketplace connecting customers and sellers while managing payments and logistics.  
Despite strong order growth, leadership suspects that revenue quality and customer retention may be weakening, leading to acquisition-driven and potentially unsustainable growth.

---

## Key Business Questions Answered
- Is revenue growth driven by higher order volume or higher order value?
- How strong is customer retention across cohorts?
- Do delivery delays affect repeat purchase behavior?
- Is revenue concentrated among a small set of sellers?
- Where should the business focus to improve sustainable growth?

---

## Key Findings (From Analysis)
- Revenue growth is primarily driven by increasing order volume rather than higher Average Order Value (AOV).
- A significant proportion of customers make only one purchase, indicating high first-order churn.
- Cohort analysis shows sharp retention drop-offs after the first month across most cohorts.
- Customers experiencing delivery delays tend to place fewer repeat orders (correlational).
- Revenue is concentrated among a small percentage of sellers, increasing operational and concentration risk.

---

## Recommendations
1. Improve first-order delivery reliability to increase repeat purchase probability.
2. Shift focus from low-value acquisition toward retention and repeat purchase incentives.
3. Actively monitor high-revenue sellers for delivery delays and operational issues.

---

## Dataset
Brazilian E-Commerce Public Dataset by Olist (Kaggle)  
- ~100,000 orders (2016–2018)
- Tables used: orders, customers, order_items, payments, sellers  
- Dataset not included in repo due to size limits

Link: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

## Tools & Skills
- SQL (joins, CTEs, window functions, cohort analysis)
- Python (pandas, matplotlib, seaborn)
- Business analytics (AOV, retention, LTV, operational risk)

---

## What This Project Demonstrates
- Ability to translate raw transactional data into business insights
- Strong SQL-first analytical workflow
- Focus on decisions and recommendations, not just visuals
- Clear communication of findings in a business context

