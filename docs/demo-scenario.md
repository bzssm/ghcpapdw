# Zava Bank 10-Minute Demo Scenario

_Last updated: 2026-05-14T08:22:11-07:00_

## 1) Setup
- Run: `docker compose up --build`
- Wait until SQL init completes and app containers report healthy.
- Expected: landing page and all app routes respond without startup errors.

## 2) Landing Page
- Open: `http://localhost`
- Expected: ZavaBank portal home with links to Auth, Accounts, Loans, Payments, Fraud, Reports, and Compliance.

## 3) Login
- Open: `http://localhost/auth/`
- Use demo credentials:
  - **Username:** `admin`
  - **Password:** `Password1!`
- Expected: successful login and active session token; no additional login required when moving between .NET and Java apps.

## 4) View Accounts
- Open: `http://localhost/accounts/`
- Search customer: `Avery Bennett` (email `extended.demo01@zavabank.com`)
- Expected data:
  - Checking account `2002-0001-0001`
  - Savings account `2002-0001-0002`
  - Recent recurring payroll deposits and bill payments in the last 90 days.

## 5) Submit Loan Application
- Open: `http://localhost/loans/`
- Start new application for `Noah Campbell` (`extended.demo02@zavabank.com`) or review seeded records.
- Seeded records to point out:
  - `Fleet expansion` = **InReview** (`extended.demo12`)
  - `Kitchen remodel` = **Submitted** (`extended.demo01`)
  - `Home office addition` = **Funded** (`extended.demo16`)
- Expected: wizard completes, status visible in loan pipeline.

## 6) Make a Payment
- Open: `http://localhost/payments/`
- Select account `2002-0016-0003` (loan account) and submit a payment.
- Expected:
  - Payment accepted and confirmation generated.
  - Corresponding ledger/transaction entry appears (loan payment pattern exists in seeded transactions).

## 7) Review Fraud Alert
- Open: `http://localhost/fraud/`
- Highlight seeded alert examples:
  - **Pending:** high amount transfer (`extended.demo05`)
  - **Escalated:** unusual location (`extended.demo07`)
  - **Cleared:** rapid transactions (`extended.demo10`)
- Expected: analyst can mark status updates with notes.

## 8) View Reports
- Open: `http://localhost/reports/`
- Generate a loan portfolio report filtered to recent applications.
- Expected: includes Submitted, Approved, Denied, InReview, and Funded statuses from extended seed data.

## 9) Compliance Check
- Open: `http://localhost/compliance/`
- Review recent filings:
  - CTR records (cash threshold events)
  - SAR records (suspicious activity narratives)
- Expected: recent FinCEN-ready entries tied to extended demo customers.

## 10) Cross-Ecosystem SSO
- While still logged in, navigate between .NET route and Java route (for example Auth → Loans → Doc Vault/Fraud).
- Expected: shared session experience with no re-login prompt.

## Demo Data Callouts
- Extended seed script: `infrastructure/sql/99-extended-seed-data.sql`
- Added:
  - 20 extended customers
  - 57 extended accounts (checking, savings, loan, CD)
  - 240+ last-90-day transactions (deposits, withdrawals, transfers, payments)
  - 6 loan applications across mixed statuses
  - documents, fraud rules, fraud alerts, and CTR/SAR compliance reports
