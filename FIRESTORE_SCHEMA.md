# NeighborCart — Firestore Data Model (Phase 2 draft)

This is the collection/field plan we'll wire the app to once Firebase is
connected. Written now so the Phase 2 service classes can be built
straight from it instead of improvising field names later.

Collections marked **(seed)** need at least one demo document manually
added (or via a one-time seed script) since Firestore starts empty —
unlike MockDataService, nothing shows up until data exists.

## users
```
users/{uid}
  name: string
  emailOrPhone: string
  avatarUrl: string?
  role: "customer" | "wholesaler"
  createdAt: timestamp
```

## pools  (seed)
```
pools/{poolId}
  name: string
  collectiveValue: number
  memberCount: number
  pickupLocation: string
  deadline: timestamp
  coordinatorUid: string
  tiers: [ { label, threshold, discountPercent } ]   // small + fixed, embed rather than subcollection
  createdAt: timestamp
```

## pool_members
```
pools/{poolId}/pool_members/{uid}
  joinedAt: timestamp
  role: "member" | "coordinator"
```

## products  (seed)
```
products/{productId}
  name: string
  description: string
  category: string
  wholesalePrice: number
  moq: number
  availableQuantity: number
  shelfLife: string
  isActive: boolean
  imageUrl: string?
  wholesalerUid: string
```

## carts
```
pools/{poolId}/carts/{uid}
  items: [ { productId, name, price, quantity } ]   // small enough to embed
  updatedAt: timestamp
```

## orders  (settlement)
```
pools/{poolId}/orders/{orderId}
  totalAmount: number
  deadline: timestamp
  status: "open" | "settled"
  createdAt: timestamp
```

## order_members
```
pools/{poolId}/orders/{orderId}/order_members/{uid}
  share: number
  itemsOrdered: number
  status: "paid" | "pending"
```

## payments
```
payments/{paymentId}
  orderId: string
  poolId: string
  uid: string
  amount: number
  paidAt: timestamp?
```

## wholesalers  (seed)
```
wholesalers/{uid}
  businessName: string
  contactName: string
  emailOrPhone: string
  createdAt: timestamp
```

## pricing_tiers
```
wholesalers/{uid}/pricing_tiers/{tierId}
  label: string
  minimumThreshold: number
  discountPercent: number
  isActive: boolean
```

## reliability
```
users/{uid}/reliability/summary
  paymentCompletionRate: number
  pickupParticipationRate: number
  completedOrders: number
  score: number   // formula left open per Master Prompt section 14
```

## pickups
```
pools/{poolId}/pickups/{pickupId}
  location: string
  scheduledFor: timestamp
  status: "scheduled" | "completed"
```

---

### Notes
- Small, fixed-shape lists (`tiers`, `items`, `productsRequested`) are
  embedded as arrays/maps rather than subcollections — cheaper reads,
  and they never grow large enough to need pagination.
- `pool_members`, `order_members`, `pricing_tiers` are subcollections
  because they can grow and benefit from being queried independently.
- Security rules aren't drafted yet — Phase 1 setup uses test mode
  (open read/write) on purpose. We'll write real rules (only a pool's
  own members can read/write its cart, only the owning wholesaler can
  edit their products, etc.) before this goes anywhere near production.
