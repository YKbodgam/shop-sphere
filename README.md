# ShopSphere

ShopSphere is a Flutter shopping catalogue application for the Prosessed technical assignment. It uses DummyJSON for authentication, product browsing, profiles, and simulated cart submission.

## Scope

The app supports:

- Secure login and session restoration
- Product catalogue browsing
- Debounced product search
- Category filtering
- Server-side sorting options
- Paginated loading and pull-to-refresh
- Product details and image gallery
- Stock-aware quantity selection
- User-scoped local cart persistence
- Cart merging, removal, quantity updates, discounts, and totals
- Simulated checkout through DummyJSON
- Order confirmation
- Profile and logout flow
- Responsive ShopSphere-inspired mobile UI

Real payments, inventory reservation, server-side order persistence, wishlist functionality, offline product caching, localization, and theme persistence are out of scope.

## Requirements

- Flutter SDK compatible with Dart `>=3.4.0 <4.0.0`
- Android Studio or Xcode
- Network access to `https://dummyjson.com`

No API key or project environment variable is required.

## Run locally

From this directory:

```bash
flutter pub get
flutter run
```

Useful commands:

```bash
dart format .
flutter analyze
flutter test
```

The reference login credentials are:

```text
Username: emilys
Password: emilyspass
```

Credentials are entered at runtime. Passwords and tokens are not stored in source code.

## Technology stack

| Concern | Implementation |
| --- | --- |
| UI | Flutter with Material 3 |
| State | `flutter_bloc` / Cubit |
| Networking | Dio |
| Routing | go_router |
| Dependency injection | get_it |
| Secure tokens | flutter_secure_storage |
| Cart persistence | user-scoped shared_preferences storage |
| Images | cached_network_image |
| Responsive sizing | flutter_screenutil |
| Static analysis | flutter_lints |

## Architecture

The code is organized by feature with shared application services:

```text
lib/
├── core/
│   ├── errors/          # Domain-safe typed failures
│   ├── network/         # Shared Dio client and auth interceptor
│   ├── participants/    # Participant update simulation
│   ├── theme/           # Material theme and visual tokens
│   └── widgets/         # Shared UI components and state widgets
├── features/
│   ├── auth/            # Login, onboarding, session and auth state
│   ├── cart/            # Cart models, persistence, Cubit and widgets
│   ├── checkout/        # Checkout submission and confirmation
│   └── products/        # Product models, repository, Cubit and widgets
└── main.dart            # App startup, dependency registration and routes
```

### Responsibility boundaries

- **Data layer:** Dio requests, response decoding, secure token storage, and local cart storage.
- **Domain layer:** Product, category, session, cart, pricing, and order representations.
- **Presentation layer:** Cubits, routes, screens, forms, cards, loading states, empty states, and error recovery.

Repositories own remote access. Cubits own feature state and asynchronous transitions. Widgets render state and dispatch user intent; they should not own API or pricing logic.

## Authentication and session behavior

1. The app initializes dependencies and local storage.
2. The splash route resolves the stored session before showing protected content.
3. Access and refresh tokens are stored with `flutter_secure_storage`.
4. `/auth/me` validates a stored session.
5. A protected 401 can trigger one coordinated refresh operation.
6. The original request is retried at most once.
7. Refresh requests do not recursively trigger the interceptor.
8. Failed refresh or invalid sessions clear local tokens and return the user to login.
9. Temporary network failures are represented as recoverable failures rather than automatically treating the session as invalid.
10. Logout clears stored session data and prevents protected-route access.

Passwords, access tokens, refresh tokens, and authorization headers must never be logged.

## DummyJSON API contract

The app uses these endpoints under `https://dummyjson.com`:

```text
POST /auth/login
GET  /auth/me
POST /auth/refresh
GET  /products?limit=20&skip=0
GET  /products/search?q={query}&limit=20&skip=0
GET  /products/category/{slug}?limit=20&skip=0
GET  /products/categories
GET  /products/{id}
POST /carts/add
```

The checkout request is built from the authenticated user ID and canonical cart product IDs and quantities:

```json
{
  "userId": 1,
  "products": [
    { "id": 144, "quantity": 2 }
  ]
}
```

DummyJSON checkout is simulated. It does not charge a payment method or guarantee permanent order storage.

## Catalogue behavior

- The first page requests 20 products.
- Search is debounced by approximately 400 ms.
- Search resets pagination and ignores stale responses.
- Category changes reset pagination and preserve the selected category for later pages.
- Sorting supports price ascending, price descending, rating, and title options.
- Duplicate products are not appended during pagination.
- Pagination stops when the loaded count reaches the reported total.
- Pull-to-refresh replaces the remote list while retaining query parameters.
- Initial loading, loading-more, empty, no-results, and recoverable error states are distinct.
- Product images use cached loading with fallbacks.

## Cart and pricing rules

The cart is local application-owned state and is scoped by authenticated user ID. Each line is uniquely identified by product ID and stores a product snapshot sufficient for rendering after restart.

Rules:

- Adding an existing product merges quantities.
- Quantity minimum is 1.
- Quantity cannot exceed known stock.
- Removing an item deletes the complete line.
- The badge is the sum of item quantities, not the number of distinct lines.
- Every mutation updates the in-memory state and persists it.
- Storage failures are surfaced rather than reported as successful persistence.
- Checkout failure preserves the cart.
- The cart clears only after a confirmed successful checkout response.

Discount and total calculations are centralized in the cart domain model. The UI does not independently recalculate totals.

## UI and responsive design

The interface follows the supplied ShopSphere references:

- Navy typography with vivid blue primary actions
- Soft blue-gray surfaces and rounded cards
- Compact ecommerce pricing hierarchy and discount badges
- Onboarding artwork and authentication composition
- Search, category chips, promotion banner, product grid, and custom bottom navigation
- Product gallery, thumbnails, stock state, highlights, quantity selector, and add-to-cart CTA
- Cart item cards, shipping banner, totals, checkout, and order confirmation

Responsive layout targets:

| Width | Layout |
| --- | --- |
| Below 600 dp | Two-column product grid and bottom navigation |
| 600–1024 dp | Three- or four-column grid and navigation rail where appropriate |
| Above 1024 dp | Expanded layouts and master-detail opportunities |

Interactive controls should provide at least 48 dp tap targets, meaningful semantic labels, safe image fallbacks, readable contrast, and layouts that tolerate increased text scale.

## Error handling

Remote and local failures are translated into safe application failures, including:

- Network unavailable
- Request timeout
- Unauthorized or expired session
- Not found
- Server failure
- Invalid or malformed response
- Local persistence failure
- Unknown failure

User-facing messages do not expose raw Dio exceptions, credentials, tokens, or server payloads. Safe GET operations may be retried through explicit UI actions; checkout POST requests are not automatically repeated.

## Important implementation decisions

- Cart ownership is user-scoped to prevent one account seeing another account's cart.
- Access-token refresh is coordinated so concurrent 401 responses share one refresh operation.
- Search, category, and sort are explicit catalogue query state rather than silently replacing one another.
- Optional API fields such as brand, reviews, and images are treated as nullable.
- Simulated checkout is labeled honestly and is not presented as a real purchase.
- The demo API cannot guarantee inventory, pricing integrity, payment security, or permanent order persistence.

## Verification

Run the following in a Flutter-capable environment before delivery:

```bash
dart format .
flutter analyze
flutter test
flutter run
```

Manual verification should cover a phone-sized layout, tablet layout, landscape orientation, larger text scale, login failure and retry, session restoration, search and pagination, category and sorting changes, product image failure, empty cart, cart persistence, checkout failure, successful checkout, logout, and session expiration.
