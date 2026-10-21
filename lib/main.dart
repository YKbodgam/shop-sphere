import 'package:cached_network_image/cached_network_image.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_cubit.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/onboarding_page.dart';
import 'features/auth/login_screen.dart';
import 'features/cart/cart.dart';
import 'features/products/domain/product.dart';
import 'features/products/product_repository.dart';
import 'features/checkout/checkout_service.dart';
import 'features/cart/cart_cubit.dart';
import 'features/products/promo_banner.dart';
import 'features/products/home_bottom_nav.dart';
import 'features/cart/cart_item_card.dart';
import 'features/cart/shipping_banner.dart';
import 'core/widgets/shopsphere_components.dart';
import 'features/profile/profile_cubit.dart';
import 'core/validation/validators.dart';

final di = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = const FlutterSecureStorage();
  final api = ApiClient(storage);
  di.registerSingleton(api);
  di.registerSingleton(storage);
  di.registerSingleton(prefs);
  di.registerSingleton(AuthRepository(api, storage));
  di.registerSingleton(ProductRepository(api));
  di.registerSingleton(CartStore(prefs));
  di.registerSingleton(CheckoutService(di<ProductRepository>()));
  runApp(const ShopSphereApp());
}

class ShopSphereApp extends StatefulWidget {
  const ShopSphereApp({super.key});
  @override
  State<ShopSphereApp> createState() => _ShopSphereAppState();
}

class _ShopSphereAppState extends State<ShopSphereApp> {
  late final AuthCubit auth;
  late final GoRouter router;
  @override
  void initState() {
    super.initState();
    auth = AuthCubit(di<AuthRepository>())..restore();
    router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(auth.stream),
      redirect: (_, state) {
        final s = auth.state;
        if (s is AuthStarting) {
          return state.uri.path == '/splash' ? null : '/splash';
        }
        if (s is AuthSignedOut || s is AuthFailure) {
          return state.uri.path == '/login' || state.uri.path == '/onboarding'
              ? null
              : '/onboarding';
        }
        if (s is AuthSignedIn &&
            (state.uri.path == '/login' || state.uri.path == '/splash')) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
        GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(
          path: '/home',
          builder: (context, _) {
            final state = context.read<AuthCubit>().state;
            final userId = state is AuthSignedIn ? state.user.id : 0;
            return ShellPage(userId: userId);
          },
        ),
        GoRoute(
          path: '/product/:id',
          builder: (_, s) =>
              ProductPage(id: int.parse(s.pathParameters['id']!)),
        ),
        GoRoute(path: '/checkout', builder: (_, _) => const CheckoutPage()),
        GoRoute(
          path: '/order-placed',
          builder: (_, state) => OrderPlacedPage(
            order: state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: auth),
        BlocProvider(create: (_) => ProfileCubit(di<AuthRepository>())..load()),
        BlocProvider(
          create: (_) => CartCubit(
            di<CartStore>(),
            userId: auth.state is AuthSignedIn
                ? (auth.state as AuthSignedIn).user.id
                : 0,
          )..load(),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_bag_rounded,
            size: 64,
            color: AppTheme.primary,
          ),
          SizedBox(height: 16.h),
          Text('ShopSphere', style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 24.h),
          const CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  final username = TextEditingController(text: 'emilys');
  final password = TextEditingController(text: 'emilyspass');
  bool obscure = true;
  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.shopping_bag_rounded,
                    size: 64,
                    color: AppTheme.primary,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue shopping',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 28.h),
                  TextFormField(
                    controller: username,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: usernameValue,
                  ),
                  SizedBox(height: 14.h),
                  TextFormField(
                    controller: password,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: 'Toggle password visibility',
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: passwordValue,
                  ),
                  SizedBox(height: 22.h),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (_, state) => state is AuthFailure
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              state.message,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (_, state) => FilledButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              if (form.currentState!.validate()) {
                                context.read<AuthCubit>().login(
                                  username.text.trim(),
                                  password.text,
                                );
                              }
                            },
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Demo credentials are prefilled for review.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, required this.userId});
  final int userId;
  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int index = 0;
  final cart = ValueNotifier<List<CartItem>>([]);
  @override
  void initState() {
    super.initState();
    di<CartStore>().load(userId: widget.userId).then((items) {
      if (mounted) cart.value = items;
    });
  }

  Future<void> updateCart(List<CartItem> items) async {
    cart.value = items;
    await di<CartStore>().save(items, userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(cart: cart, onCartChanged: updateCart),
      CartPage(cart: cart, onCartChanged: updateCart),
      ProfilePage(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: HomeBottomNav(
        index: index,
        cartCount: cart.value.fold<int>(0, (sum, item) => sum + item.quantity),
        onChanged: (value) {
          if (value == 2) {
            setState(() => index = 1);
          } else if (value == 3) {
            setState(() => index = 2);
          } else {
            setState(() => index = 0);
          }
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.cart, required this.onCartChanged});
  final ValueNotifier<List<CartItem>> cart;
  final Future<void> Function(List<CartItem>) onCartChanged;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repo = di<ProductRepository>();
  final search = TextEditingController();
  Timer? searchDebounce;
  int requestId = 0;
  List<Product> products = [];
  List<Category> categories = [];
  String? category;
  String? sort;
  String order = 'asc';
  bool loading = true;
  bool loadingMore = false;
  String? error;
  int skip = 0;
  int total = 0;
  @override
  void initState() {
    super.initState();
    load();
    repo.categories().then((items) {
      if (mounted) setState(() => categories = items);
    });
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    search.dispose();
    super.dispose();
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      skip = 0;
      products = [];
      error = null;
    }
    if (skip == 0) {
      setState(() => loading = true);
    } else {
      setState(() => loadingMore = true);
    }
    try {
      final page = await repo.list(
        skip: skip,
        query: search.text,
        category: category,
        sort: sort,
        order: order,
      );
      if (mounted) {
        setState(() {
          products = [...products, ...page.products];
          total = page.total;
          skip = products.length;
          loading = false;
          loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          loading = false;
          loadingMore = false;
        });
      }
    }
  }

  Future<void> add(Product product) async {
    final current = [...widget.cart.value];
    final i = current.indexWhere((item) => item.product.id == product.id);
    if (i >= 0) {
      current[i] = current[i].copyWith(quantity: current[i].quantity + 1);
    } else {
      current.add(CartItem(product: product, quantity: 1));
    }
    await widget.onCartChanged(current);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Added to cart')));
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () => load(refresh: true),
    child: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(
            'ShopSphere',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Sort products',
              onSelected: (value) {
                setState(() {
                  sort = value == 'default' ? null : value;
                  order = value == 'price_desc' ? 'desc' : 'asc';
                });
                load(refresh: true);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'default', child: Text('Recommended')),
                PopupMenuItem(
                  value: 'price',
                  child: Text('Price: low to high'),
                ),
                PopupMenuItem(
                  value: 'price_desc',
                  child: Text('Price: high to low'),
                ),
                PopupMenuItem(
                  value: 'rating',
                  child: Text('Rating: highest first'),
                ),
                PopupMenuItem(value: 'title', child: Text('Title: A-Z')),
              ],
            ),
            IconButton(
              tooltip: 'Cart',
              onPressed: () => context.go('/home'),
              icon: ValueListenableBuilder<List<CartItem>>(
                valueListenable: widget.cart,
                builder: (_, items, _) => Badge(
                  label: Text('${items.length}'),
                  isLabelVisible: items.isNotEmpty,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: search,
              onChanged: (_) {
                searchDebounce?.cancel();
                searchDebounce = Timer(const Duration(milliseconds: 400), () {
                  if (mounted) load(refresh: true);
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    search.clear();
                    load(refresh: true);
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = i == 0
                    ? category == null
                    : category == categories[i - 1].slug;
                return ChoiceChip(
                  label: Text(i == 0 ? 'All' : categories[i - 1].name),
                  selected: selected,
                  onSelected: (_) {
                    setState(
                      () => category = i == 0 ? null : categories[i - 1].slug,
                    );
                    load(refresh: true);
                  },
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: PromoBanner()),
        loading
            ? const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            : error != null
            ? SliverFillRemaining(
                child: ErrorView(
                  message: error!,
                  onRetry: () => load(refresh: true),
                ),
              )
            : (products.isEmpty)
            ? SliverFillRemaining(
                child: Center(child: Text('No products found')),
              )
            : SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((_, i) {
                    if (i == products.length) {
                      return loadingMore
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink();
                    }
                    final p = products[i];
                    return ProductCard(
                      product: p,
                      onTap: () => context.push('/product/${p.id}'),
                      onAdd: () => add(p),
                    );
                  }, childCount: products.length + (skip < total ? 1 : 0)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.sizeOf(context).width >= 1000
                        ? 4
                        : MediaQuery.sizeOf(context).width >= 600
                        ? 3
                        : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .64,
                  ),
                ),
              ),

        ?skip < total
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: OutlinedButton(
                      onPressed: loadingMore ? null : load,
                      child: const Text('Load more'),
                    ),
                  ),
                ),
              )
            : null,
      ],
    ),
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppTheme.surface),
                  errorWidget: (_, _, _) =>
                      const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: AppTheme.primary),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                Text(' ${product.rating.toStringAsFixed(1)}'),
                const Spacer(),
                IconButton(
                  tooltip: 'Add to cart',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.id});
  final int id;
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product? product;
  int quantity = 1;
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    di<ProductRepository>()
        .details(widget.id)
        .then((value) {
          if (mounted) {
            setState(() {
              product = value;
              loading = false;
            });
          }
        })
        .catchError((e) {
          if (mounted) {
            setState(() {
              error = e.toString();
              loading = false;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: error ?? 'Product not found',
          onRetry: () => setState(() => loading = true),
        ),
      );
    }
    final p = product!;
    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: PageView(
              children: (p.images.isEmpty ? [p.thumbnail] : p.images)
                  .map(
                    (url) => CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.image_not_supported_outlined),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (p.images.isEmpty ? [p.thumbnail] : p.images).length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Container(
                width: 58,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: i == 0 ? AppTheme.primary : const Color(0xFFE8EDF5),
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: (p.images.isEmpty ? [p.thumbnail] : p.images)[i],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
          if (p.brand != null) Text(p.brand!),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              Text(
                ' ${p.rating.toStringAsFixed(1)} (${p.reviews.length} reviews)',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '\$${p.price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: AppTheme.ink),
              ),
              const SizedBox(width: 10),
              Text(
                '\$${(p.price * 1.25).toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppTheme.muted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 10),
              const DiscountBadge(value: 25),
            ],
          ),
          const SizedBox(height: 12),
          Text(p.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final feature in [
                'Noise Cancellation',
                'Long Battery',
                'Bluetooth 5.3',
              ])
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        feature == 'Bluetooth 5.3'
                            ? Icons.bluetooth
                            : Icons.graphic_eq,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'In Stock',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Free shipping',
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Quantity', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$quantity'),
              IconButton(
                onPressed: quantity < p.stock
                    ? () => setState(() => quantity++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: p.inStock
                ? () async {
                    final store = di<CartStore>();
                    final items = await store.load();
                    final i = items.indexWhere(
                      (item) => item.product.id == p.id,
                    );
                    if (i >= 0) {
                      items[i] = items[i].copyWith(
                        quantity: items[i].quantity + quantity,
                      );
                    } else {
                      items.add(CartItem(product: p, quantity: quantity));
                    }
                    await store.save(items);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                      context.go('/home');
                    }
                  }
                : null,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text(p.inStock ? 'Add to Cart' : 'Out of stock'),
          ),
          const SizedBox(height: 18),
          Text(
            'Customer reviews',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ...p.reviews.map(
            (review) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(review.reviewerName),
              subtitle: Text('${review.rating}/5 · ${review.comment}'),
            ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key, required this.cart, required this.onCartChanged});
  final ValueNotifier<List<CartItem>> cart;
  final Future<void> Function(List<CartItem>) onCartChanged;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: cart,
      builder: (_, items, _) {
        final totals = calculateTotals(items);
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Cart'),
            actions: [
              if (items.isNotEmpty)
                IconButton(
                  tooltip: 'Clear cart',
                  onPressed: () => onCartChanged([]),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: items.isEmpty
              ? const EmptyCartView()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final item = items[i];
                          return CartItemCard(
                            item: item,
                            onRemove: () {
                              final next = [...items]..removeAt(i);
                              onCartChanged(next);
                            },
                            onDecrease: () {
                              final next = [...items];
                              if (item.quantity == 1) {
                                next.removeAt(i);
                              } else {
                                next[i] = item.copyWith(
                                  quantity: item.quantity - 1,
                                );
                              }
                              onCartChanged(next);
                            },
                            onIncrease: item.quantity < item.product.stock
                                ? () {
                                    final next = [...items];
                                    next[i] = item.copyWith(
                                      quantity: item.quantity + 1,
                                    );
                                    onCartChanged(next);
                                  }
                                : () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          const ShippingBanner(),
                          const SizedBox(height: 12),
                          SummaryRow(
                            label: 'Subtotal',
                            value: '\$${totals.subtotal.toStringAsFixed(2)}',
                          ),
                          SummaryRow(
                            label: 'Discount',
                            value: '-\$${totals.discount.toStringAsFixed(2)}',
                          ),
                          const Divider(),
                          SummaryRow(
                            label: 'Total',
                            value: '\$${totals.total.toStringAsFixed(2)}',
                            emphasized: true,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => context.push('/checkout'),
                              child: const Text('Proceed to Checkout'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final form = GlobalKey<FormState>();
  bool placing = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Checkout')),
    body: FutureBuilder<List<CartItem>>(
      future: di<CartStore>().load(
        userId: context.read<AuthCubit>().state is AuthSignedIn
            ? (context.read<AuthCubit>().state as AuthSignedIn).user.id
            : 0,
      ),
      builder: (_, snapshot) {
        final items = snapshot.data ?? [];
        final totals = calculateTotals(items);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Shipping Address',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Form(
              key: form,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: requiredField,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Street address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: requiredField,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: requiredField,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Order summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...items.map(
              (item) => ListTile(
                title: Text(item.product.title),
                subtitle: Text('Qty: ${item.quantity}'),
                trailing: Text(
                  '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                ),
              ),
            ),
            SummaryRow(
              label: 'Total',
              value: '\$${totals.total.toStringAsFixed(2)}',
              emphasized: true,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: placing || items.isEmpty
                    ? null
                    : () async {
                        if (!form.currentState!.validate()) return;
                        setState(() => placing = true);
                        try {
                          final authState = context.read<AuthCubit>().state;
                          final userId = authState is AuthSignedIn
                              ? authState.user.id
                              : 0;
                          final response = await di<CheckoutService>().submit(
                            userId: userId,
                            items: items,
                          );
                          await di<CartStore>().clear(userId: userId);
                          if (context.mounted) {
                            context.go(
                              '/order-placed',
                              extra: response.toJson(),
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not place order. ${error.toString()}',
                                ),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => placing = false);
                        }
                      },
                child: placing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Place Order'),
              ),
            ),
          ],
        );
      },
    ),
  );
}

String? requiredField(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required' : null;

class OrderPlacedPage extends StatelessWidget {
  const OrderPlacedPage({super.key, this.order});
  final Map<String, dynamic>? order;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: AppTheme.paleBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  size: 66,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Order Placed!',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'This is a simulated order. No real payment will be charged.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
              const SizedBox(height: 24),
              SoftCard(
                child: Column(
                  children: [
                    SummaryRow(
                      label: 'Order ID',
                      value: order?['id']?.toString() ?? 'Simulated order',
                    ),
                    SummaryRow(
                      label: 'Total Amount',
                      value: order?['total']?.toString() ?? 'Submitted',
                    ),
                    SummaryRow(
                      label: 'Items',
                      value:
                          order?['totalProducts']?.toString() ??
                          'Submitted cart',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Back to Home',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('View Order Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProfileFailure) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<ProfileCubit>().load(),
          );
        }
        final user = state is ProfileReady ? state.user : null;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundImage: user?.image == null
                    ? null
                    : CachedNetworkImageProvider(user!.image!),
                child: user?.image == null
                    ? const Icon(Icons.person, size: 44)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user?.name ?? 'ShopSphere user',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Center(
              child: Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                user?.phone ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(user?.email ?? 'Not available'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Phone'),
                    subtitle: Text(user?.phone ?? 'Not available'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.read<AuthCubit>().logout(
                  'You have been signed out.',
                ),
                child: const Text('Log out'),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label, value;
  final bool emphasized;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: emphasized ? Theme.of(context).textTheme.titleMedium : null,
        ),
        Text(
          value,
          style: emphasized ? Theme.of(context).textTheme.titleLarge : null,
        ),
      ],
    ),
  );
}

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shopping_cart_outlined, size: 64),
        const SizedBox(height: 16),
        Text(
          'Your cart is empty',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text('Add products to see them here.'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.go('/home'),
          child: const Text('Start Shopping'),
        ),
      ],
    ),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
