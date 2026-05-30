# Cash-Stakes Duels — Brief for Legal Review

**Status:** Planning only. No real-money code is built. This document is meant to
hand to counsel before any cash feature ships.

## 1. What we want to build

Users compete head-to-head to have the *lower screen time* over a fixed window
(day/week/month/year). We want an optional tier where each participant puts up
**real money**; the winner takes the pot and the app keeps a small fee ("rake").

Three stake types exist in the app today, in increasing order of risk:

| Tier | Stake | Real money? | Status |
| --- | --- | --- | --- |
| Friendly | Points / pride | No | Built |
| Coins | In-app coins (no purchase, no cash-out) | No | Built |
| Charity forfeit | Lose → donate to charity | Yes (donation only) | Built |
| **Cash pot** | **Each stakes $, winner takes pot, app takes rake** | **Yes** | **Not built — this brief** |

## 2. Key legal questions for counsel

1. **Gambling / "skill vs. chance."** Pay-to-enter + prize + outcome can meet the
   legal definition of gambling. Our argument: screen time is predominantly
   within the user's control, so this is a *contest of skill*, not chance. Which
   states accept this, and which prohibit it regardless (e.g. AZ, AR, CT, DE, LA,
   MT, SC, SD, TN)? Do we geofence those states out?
2. **Money transmission.** If the app holds user funds in escrow and pays out, are
   we a "money transmitter" needing state MTLs / FinCEN registration? Assumption:
   we avoid this entirely by never touching funds — a licensed payments partner
   holds and disburses (see §3).
3. **App Store / Play Store compliance.** Apple Guideline 5.3 (gaming, gambling,
   contests) and the rules on real-money contests. Do we need to register the app
   as a contest, restrict regions, or use an approved partner?
4. **Consumer-protection / sweepstakes law.** Disclosure, terms, "no purchase
   necessary" alternatives, refunds, dispute handling.
5. **Tax reporting.** Do winnings trigger 1099 obligations? Who issues them — us or
   the payments partner?
6. **Age gating.** Minimum age for cash play (likely 18+), and how we verify.

## 3. Proposed architecture (de-risks money transmission)

The app **never holds money.** A regulated third party does custody + payout:

- Candidates: **Stripe Connect** (with escrow-style holds), **PayPal/Braintree**,
  or a contest-specialist platform.
- Flow: both users authorize a hold → duel resolves → partner releases the pot to
  the winner minus our application fee → partner handles payout + compliance.
- Our servers store only duel state and the partner's transaction references.

This keeps us out of fund custody and pushes KYC/AML/payout licensing onto the
partner.

## 4. Technical readiness (already done)

The `Duel` model and `DataService` seam are built so a real-money tier slots in
without UI rework:
- `Duel.wager` / `Duel.pot` already model stakes.
- `Duel.Forfeit` already models a "lose → pay" pledge (currently charity).
- A `CashStake` type + `PaymentService` protocol would mirror the existing
  `DataService` pattern; the mock stays for dev, the real partner SDK backs prod.

## 5. Recommended sequence

1. Ship friendly + coin + charity tiers now (no cash) — validate demand.
2. Counsel review of this brief; pick states to support; pick payments partner.
3. Build `PaymentService` against the partner's sandbox.
4. Legal sign-off on terms, disclosures, age gate, geofencing.
5. Limited launch in approved states.

## 6. Open decisions for the founder

- Max stake size? (Lower = less regulatory attention.)
- Rake percentage?
- Charity-forfeit payout: who is the merchant of record for the donation?
- Launch states vs. geofenced-out states.
