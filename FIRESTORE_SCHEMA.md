# NeighborCart — Firestore data model (as implemented)

```
users/{uid}
  role: "customer" | "wholesaler", email, createdAt
  customer:   name, activePoolId, joinedPoolIds[]
  wholesaler: businessName, contactName
  orders/{poolId}                      # one order per member per pool
    poolId, poolName, orderNumber, amount (member share), poolTotal,
    status: "pending" | "paid", updatedAt

pools/{poolId}
  name, pickupLocation, deadline, coordinatorName, coordinatorUid,
  orderNumber, memberCount, createdAt, updatedAt
  collectiveValue            # sum of all members' cart subtotals (list price)
  demand: { productId: { name, qty } }   # aggregated demand, kept in sync
  pool_members/{uid}   name, role, joinedAt
  carts/{uid}          items[{productId,name,description,price,quantity}], subtotal, updatedAt
  payments/{uid}       uid, amount, paidAt

products/{productId}
  name, description, category, wholesalePrice (unit price shown to customers),
  moq, availableQuantity, shelfLife, isActive, wholesalerUid, createdAt

config/pricing
  tiers: [ { id, label, minimumThreshold, discountPercent, isActive } ]
```

## How the numbers work
- Cart changes run in a transaction that updates the member's cart AND the
  pool's `collectiveValue` / `demand` together.
- Discount = highest active tier whose `minimumThreshold` <= `collectiveValue`
  (see `lib/core/utils/price_break.dart`). A member's cost = subtotal x (1 - discount).
- A pool's MOQ is "reached" when every requested product (of that wholesaler)
  has total demand >= its MOQ.

## Not done yet
- Pricing/settlement math runs on the client (Cloud Functions need the paid plan).
- Weekly cycle reset, coordinator rotation, reliability score, creating pools in-app.
- Real security rules (current rules are fully open — demo only).
