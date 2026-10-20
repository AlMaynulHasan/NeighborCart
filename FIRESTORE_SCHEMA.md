# NeighborCart — Firestore data model (as implemented)

```
users/{uid}
  role: "customer" | "wholesaler", email, createdAt
  customer:   name, activePoolId, joinedPoolIds[], householdSize (default 4)
  wholesaler: businessName, contactName
  reliability/summary                  # cycles, paid, pickedUp (counters), updatedAt
  orders/{poolId}                      # one order per member per pool
    poolId, poolName, orderNumber, amount (member share), poolTotal,
    status: "pending" | "paid", updatedAt

pools/{poolId}
  name, pickupLocation, deadline, coordinatorName, coordinatorUid,
  orderNumber, memberCount, createdAt, updatedAt
  status: "open" | "ordered" | "ready"   # weekly cycle (missing = open)
  collectiveValue            # sum of all members' cart subtotals (list price)
  demand: { productId: { name, qty } }   # aggregated demand, kept in sync
  pool_members/{uid}   name, role, joinedAt
  carts/{uid}          items[{productId,name,description,price,quantity}], subtotal, updatedAt
  payments/{uid}       uid, amount, paidAt
  pickups/{uid}        pickedUp, at, markedBy       # coordinator ticks members as they collect
  cycles/{orderNumber} coordinator, collectiveValue, completedAt, members[{uid,name,paid,pickedUp}]

products/{productId}
  name, description, category, wholesalePrice (unit price shown to customers),
  moq, availableQuantity, shelfLife, isActive, wholesalerUid, createdAt,
  shelfLifeDays (parsed from shelfLife), unitLastsDays (days one unit lasts for one person, optional)

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

## Basket suggestions
Rule-based, no AI: units = ceil(household x cover / unitLastsDays), cover = min(30, shelfLifeDays), and never more
than floor(household x shelfLifeDays / unitLastsDays). Cart lines above that limit get a warning. Products without
`unitLastsDays` get no suggestion. Logic lives in `lib/core/utils/basket_advisor.dart` (unit tested).

## Reliability score
When a coordinator completes a cycle, every member who ordered gets `cycles +1`, `paid +1` if they paid and
`pickedUp +1` if they collected (demo/seed members are skipped). Score = (paymentWeight x paid/cycles +
pickupWeight x pickedUp/cycles) / (paymentWeight + pickupWeight) x 100, shown on Profile and next to members
on the pickup screen. Change the weights by creating/editing `config/reliability` in the Firebase console.

## Not done yet
- Pricing/settlement math runs on the client (Cloud Functions need the paid plan).
- Writing other members' reliability counters from the coordinator's device only works with open rules;
  with real security rules this must move to a trusted server (Cloud Function) or be restricted.
- Real security rules (current rules are fully open — demo only).
