class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1/',
  );

  static const int connectTimeoutMs = 15000;
  static const int sendTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  static const String login = 'auth/login/';
  static const String register = 'auth/register/';
  static const String refreshToken = 'auth/refresh/';
  static const String userProfile = 'auth/me/';

  // ---------------------------------------------------------------------------
  // Email verification
  // ---------------------------------------------------------------------------

  static const String verifyEmail = 'auth/email/verify/';
  static const String resendEmailVerification = 'auth/email/resend/';

  // ---------------------------------------------------------------------------
  // Password recovery / security
  // ---------------------------------------------------------------------------

  static const String forgotPassword = 'auth/password/forgot/';
  static const String verifyPasswordResetCode = 'auth/password/verify/';
  static const String resetPassword = 'auth/password/reset/';
  static const String changePassword = 'auth/password/change/';

  // ---------------------------------------------------------------------------
  // Addresses
  // ---------------------------------------------------------------------------

  static const String addresses = 'auth/addresses/';

  static String addressDetail(
    Object addressId,
  ) {
    return 'auth/addresses/$addressId/';
  }

  // ---------------------------------------------------------------------------
  // Stores
  // ---------------------------------------------------------------------------

  static const String stores = 'stores/';

  static String storeDetail(
    Object storeId,
  ) {
    return 'stores/$storeId/';
  }

  // ---------------------------------------------------------------------------
  // Catalog
  // ---------------------------------------------------------------------------

  static const String categories = 'catalog/categories/';
  static const String products = 'catalog/products/';
  static const String deals = 'catalog/products/deals/';
  static const String search = 'catalog/products/search/';

  static String productDetail(
    Object productId,
  ) {
    return 'catalog/products/$productId/';
  }

  // ---------------------------------------------------------------------------
  // Inventory
  // ---------------------------------------------------------------------------

  static const String inventory = 'inventory/';

  // ---------------------------------------------------------------------------
  // Cart
  // ---------------------------------------------------------------------------

  static const String cart = 'cart/';
  static const String cartItems = 'cart/items/';
  static const String clearCart = 'cart/clear/';
  static const String validateCart = 'cart/validate/';

  static String cartItem(
    Object itemId,
  ) {
    return 'cart/items/$itemId/';
  }

  static String removeCartItem(
    Object itemId,
  ) {
    return 'cart/items/$itemId/remove/';
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  static const String orders = 'orders/';
  static const String checkout = 'orders/checkout/';

  static String orderDetail(
    Object orderId,
  ) {
    return 'orders/$orderId/';
  }

  // ---------------------------------------------------------------------------
  // Payments
  // ---------------------------------------------------------------------------

  static const String initializePayment = 'payments/initialize/';
  static const String verifyPayment = 'payments/verify/';

  // ---------------------------------------------------------------------------
  // Delivery
  // ---------------------------------------------------------------------------

  static String deliveryDetail(
    Object deliveryId,
  ) {
    return 'delivery/$deliveryId/';
  }

  // ---------------------------------------------------------------------------
  // Promotions
  // ---------------------------------------------------------------------------

  static const String promotions = 'promotions/';

  // ---------------------------------------------------------------------------
  // Loyalty
  // ---------------------------------------------------------------------------

  static const String loyalty = 'loyalty/';

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  static const String notifications = 'notifications/';

  // ---------------------------------------------------------------------------
  // Reviews
  // ---------------------------------------------------------------------------

  static const String reviews = 'reviews/';

  static String productReviews(
    Object productId,
  ) {
    return 'reviews/products/$productId/';
  }

  static String productReviewSummary(
    Object productId,
  ) {
    return 'reviews/products/$productId/summary/';
  }

  static String reviewEligibility(
    Object productId,
  ) {
    return 'reviews/products/$productId/eligibility/';
  }

  // ---------------------------------------------------------------------------
  // Support
  // ---------------------------------------------------------------------------

  static const String supportTickets = 'support/';

  static String supportTicket(
    Object ticketId,
  ) {
    return 'support/$ticketId/';
  }

  static String supportTicketReply(
    Object ticketId,
  ) {
    return 'support/$ticketId/reply/';
  }
}
