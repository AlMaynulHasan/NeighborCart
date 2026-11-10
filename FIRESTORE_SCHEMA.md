# NeighborCart — Firestore data model (as implemented)

```
users/{uid}
  role: "customer" | "wholesaler", email, createdAt, termsAcceptedAt
  customer:   name, activePoolId, joinedPoolIds[], householdSize (default 4)
  wholesaler: businessName, contactName, licenseNumber
  reliability/summary                  # cycles, paid, pickedUp (counters), updatedAt, lastPoolId
  lastBaskets/{poolId}                 # items of the last paid basket (for "reorder last week")
  bids/{poolId}                        # wholesaler's own copy of their bids
  orders/{poolId}                      # one order per member per pool
    poolId, poolName, orderNumber, amount (member share), poolTotal,
    status: "pending" | "paid", retail, method, phoneLast4, txnId (simulated payment), updatedAt

pools/{poolId}
  name, area, pickupLocation, deadline, coordinatorName, coordinatorUid,
  supplierUid, supplierName, supplierExtraPercent   # set when the coordinator picks a wholesaler's bid,
  orderNumber, memberCount, createdAt, updatedAt
  status: "open" | "ordered" | "ready"   # weekly cycle (missing = open)
  collectiveValue            # sum of all members' cart subtotals (list price)
  demand: { productId: { name, qty } }   # aggregated demand, kept in sync
  pool_members/{uid}   name, role, joinedAt
  carts/{uid}          items[{productId,name,description,price,quantity}], subtotal, updatedAt
  payments/{uid}       uid, amount, method, phoneLast4, txnId, paidAt   # simulated checkout
  pickups/{uid}        pickedUp, at, markedBy       # coordinator ticks members as they collect
  bids/{wholesalerUid} poolId, poolName, wholesalerUid, wholesalerName, licenseNumber, extraPercent (0-15), note, createdAt
  cycles/{orderNumber} coordinator, collectiveValue, completedAt, members[{uid,name,paid,pickedUp}]

products/{productId}
  name, description, category, wholesalePrice (unit price shown to customers),
  moq, availableQuantity, shelfLife, isActive, wholesalerUid, createdAt,
  shelfLifeDays (parsed from shelfLife), unitLastsDays (days one unit lasts for one person, optional)

reports/{id}
  uid, category, message, poolId?, poolName?, status, createdAt     # "Report a problem"

config/pricing
  tiers: [ { id, label, minimumThreshold, discountPercent, isActive } ]

config/reliability                     # optional; defaults to 50 / 50
  paymentWeight, pickupWeight
```

## How the numbers work
- Cart changes run in a transaction that updates the member's cart AND the
  pool's `collectiveValue` / `demand` together.
- Discount = highest active tier whose `minimumThreshold` <= `collectiveValue`
  (see `lib/core/utils/price_break.dart`). A member's cost = subtotal x (1 - discount).
- A pool's MOQ is "reached" when every requested product (of that wholesaler)
  has total demand >= its MOQ.

## Weekly cycle
open -> (coordinator) Place Order -> ordered -> Mark Goods Received -> ready -> members picked up ->
Complete Cycle: archives to `cycles/`, passes coordinator to the next member (join order), clears carts/payments/pickups,
bumps `orderNumber`, pushes `deadline` a week and re-opens the pool. Cart changes are refused once the pool is not open
or the member has paid.

## Community demand and bids
Wholesalers see open pools grouped by `area` (totals only, never individual baskets) and can bid an extra discount (0-15%)
on a pool. The pool's coordinator picks one bid; that wholesaler becomes the pool's supplier and the extra percent is
added to the tier discount for every member (`PriceBreak.extraPercent`). A saved trade/food licence number is required to bid.

## Payments (simulated)
"Pay Now" opens a bKash / Nagad / card style sheet, then a receipt. No money moves and no account is contacted; only the
last 4 digits of the number and a generated transaction id are stored. A real launch needs a licensed payment provider.

## Basket suggestions
Rule-based, no AI: units = ceil(household x cover / unitLastsDays), cover = min(30, shelfLifeDays), and never more
than floor(household x shelfLifeDays / unitLastsDays). Cart lines above that limit get a warning. Products without
`unitLastsDays` get no suggestion. Logic lives in `lib/core/utils/basket_advisor.dart` (unit tested).

## Reliability score
When a coordinator completes a cycle, every member who ordered gets `cycles +1`, `paid +1` if they paid and
`pickedUp +1` if they collected (demo/seed members are skipped). Score = (paymentWeight x paid/cycles +
pickupWeight x pickedUp/cycles) / (paymentWeight + pickupWeight) x 100, shown on Profile and next to members
on the pickup screen. Change the weights by creating/editing `config/reliability` in the Firebase console.

## Security rules (`firestore.rules`)
- Only signed-in users can read anything; a user can only read/write their own `users/{uid}` and `orders`.
- The account role (customer/wholesaler) is fixed at sign-up.
- Pools: anyone signed in can read; creator becomes coordinator; join = +1 member count with your own member doc;
  a member's cart change must move `collectiveValue` by exactly the cart subtotal change, only while the pool is open
  and before the deadline, and not after paying. Only the coordinator can place the order, mark ready, tick pickups,
  complete the cycle and clear carts/payments.
- Products: only the owning wholesaler can create/edit/delete. `config/pricing`: wholesalers; `config/reliability`: console only.
- Demo shortcut: ids starting with `seed_` may be written by anyone (for "Load demo pools"). Remove before launch.

## Not done yet
- Pricing/settlement math runs on the client (Cloud Functions need the paid plan).
- Writing other members' reliability counters from the coordinator's device only works with open rules;
  with real security rules this must move to a trusted server (Cloud Function) or be restricted.
- Payment amounts and member shares are computed on the client, so rules can't fully verify them (needs Cloud Functions).
- Real payments, community-manager and delivery-partner roles, wholesaler approval/verification.
