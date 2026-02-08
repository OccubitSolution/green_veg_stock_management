/// App Routes
///
/// All route names for the application
abstract class AppRoutes {
  AppRoutes._();

  // Auth
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const pinSetup = '/pin-setup';
  static const pinLock = '/pin-lock';

  // Main
  static const home = '/home';
  static const dashboard = '/dashboard';

  // Products
  static const products = '/products';
  static const productDetail = '/products/detail';
  static const addProduct = '/products/add';
  static const editProduct = '/products/edit';
  static const categories = '/categories';
  static const units = '/units';

  // Daily Prices
  static const dailyPrices = '/daily-prices';
  static const priceEntry = '/daily-prices/entry';
  static const priceHistory = '/daily-prices/history';

  // Purchases
  static const purchases = '/purchases';
  static const purchaseDetail = '/purchases/detail';
  static const addPurchase = '/purchases/add';

  // Sales
  static const sales = '/sales';
  static const saleDetail = '/sales/detail';
  static const addSale = '/sales/add';

  // Orders
  static const orders = '/orders';
  static const orderDetail = '/orders/detail';
  static const addOrder = '/orders/add';
  static const purchaseList = '/orders/purchase-list';

  // Customers
  static const customers = '/customers';
  static const customerDetail = '/customers/detail';
  static const addCustomer = '/customers/add';

  // Suppliers
  static const suppliers = '/suppliers';
  static const supplierDetail = '/suppliers/detail';
  static const addSupplier = '/suppliers/add';

  // Stock
  static const stock = '/stock';
  static const stockMovement = '/stock/movement';

  // Reports
  static const reports = '/reports';
  static const purchaseReport = '/reports/purchase';
  static const salesReport = '/reports/sales';
  static const priceTrends = '/reports/price-trends';
  static const analytics = '/reports/analytics';

  // Settings
  static const settings = '/settings';
  static const profile = '/settings/profile';
  static const language = '/settings/language';
  static const changePassword = '/settings/change-password';
  static const changePin = '/settings/change-pin';
}
