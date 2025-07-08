import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:ebook_tuh/data/dummy.dart';
import 'package:ebook_tuh/views/main_wrapper/main_wrapper_cubit.dart';
import 'package:ebook_tuh/views/subscription_plan/subscription_cubit.dart';
import 'package:ebook_tuh/views/subscription_plan/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

import '../../constants/app_color.dart';
import '../../models/premium_plans.dart';
import '../../models/user_subscription.dart';

class SubscriptionPlansPage extends StatefulWidget {
  const SubscriptionPlansPage({super.key});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage>
    with SingleTickerProviderStateMixin {
  bool _isCurrentPlanExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    context.read<SubscriptionCubit>().fetchSubscriptionData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<MainWrapperCubit>().setBottomNavigationVisibility(true);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Gói Đăng Ký',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      backgroundColor: const Color(0xFF2C5F5F),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C5F5F), Color(0xFF1E4A4A)],
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, SubscriptionState state) {
    if (state.errorMessage != null) {
      _showSnackBar(context, state.errorMessage!, isError: true);
      context.read<SubscriptionCubit>().clearMessages();
    }

    if (state.successMessage != null) {
      _showSnackBar(context, state.successMessage!, isError: false);
      context.read<SubscriptionCubit>().clearMessages();
    }

    if (state.status == SubscriptionStatus.paymentProcessing &&
        state.clientSecretForPayment != null) {
      debugPrint('Vào luồng thanh toán Stripe');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleStripePayment(context, state.clientSecretForPayment!);
      });
    }
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SubscriptionState state) {
    if (state.status == SubscriptionStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == SubscriptionStatus.loaded && state.availablePremiumPlans.isEmpty) {
      return _buildErrorState(state);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<SubscriptionCubit>().fetchSubscriptionData(),
      color: const Color(0xFF2C5F5F),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentSubscriptionSection(context, state.currentUserSubscription),
                  const SizedBox(height: 32),
                  _buildAvailablePlansHeader(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildPlansList(context, state),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C5F5F)),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SubscriptionState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${state.errorMessage}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<SubscriptionCubit>().fetchSubscriptionData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5F5F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailablePlansHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF2C5F5F),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Các gói có sẵn',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPlansList(BuildContext context, SubscriptionState state) {
    if (state.availablePremiumPlans.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'Không có gói đăng ký nào khả dụng.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final plan = state.availablePremiumPlans[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildPlanCard(context, plan, state, index),
          );
        },
        childCount: state.availablePremiumPlans.length,
      ),
    );
  }

  Widget _buildCurrentSubscriptionSection(BuildContext context, UserSubscription? subscription) {
    final availablePlans = context.read<SubscriptionCubit>().state.availablePremiumPlans;

    if (subscription != null && subscription.isActive) {
      return _buildActiveSubscriptionCard(context, subscription, availablePlans);
    } else {
      return _buildNoSubscriptionCard();
    }
  }

  Widget _buildActiveSubscriptionCard(
      BuildContext context, UserSubscription subscription, List<PremiumPlan> availablePlans) {
    final currentPlan = availablePlans.firstWhere(
          (p) => p.planId == subscription.planId,
      orElse: () => _getUnknownPlan(),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Gói đăng ký hiện tại',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentPlan?.name ?? 'Không xác định',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildSubscriptionDateInfo(subscription),
            const SizedBox(height: 16),
            _buildExpandableDetails(currentPlan),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: _buildManageButton(context, subscription, currentPlan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDateInfo(UserSubscription subscription) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDateRow('Bắt đầu', subscription.startDate, Icons.play_arrow),
          const SizedBox(height: 8),
          _buildDateRow('Kết thúc', subscription.endDate, Icons.stop),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ${date.day}/${date.month}/${date.year}',
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildExpandableDetails(PremiumPlan? currentPlan) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
        ),
      ),
      child: ExpansionTile(
        key: ValueKey(currentPlan?.planId),
        tilePadding: EdgeInsets.zero,
        title: const Text(
          'Thông tin chi tiết gói',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        trailing: AnimatedRotation(
          turns: _isCurrentPlanExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 300),
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isCurrentPlanExpanded = expanded;
          });
        },
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentPlan?.description ?? 'Không có thông tin chi tiết.',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageButton(BuildContext context, UserSubscription subscription, PremiumPlan? currentPlan) {
    return ElevatedButton.icon(
      onPressed: () => _showManageSubscriptionOptions(context, subscription, currentPlan),
      icon: const Icon(Icons.settings, size: 20),
      label: const Text('Quản lý gói'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildNoSubscriptionCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[200]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Chưa có gói đăng ký',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có gói đăng ký Premium nào.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nâng cấp để truy cập đầy đủ các tính năng!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, PremiumPlan plan, SubscriptionState state, int index) {
    final isProcessing = state.status == SubscriptionStatus.paymentProcessing &&
        context.read<SubscriptionCubit>().state.currentUserSubscription?.planId == plan.planId;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.shade400,
                    Colors.teal.shade600,
                    Colors.teal.shade800,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanHeader(plan),
                    const SizedBox(height: 16),
                    if (plan.description != null) _buildPlanDescription(plan),
                    const SizedBox(height: 24),
                    _buildPlanPrice(plan),
                    const SizedBox(height: 24),
                    _buildPlanFeatures(plan),
                    const SizedBox(height: 32),
                    _buildPurchaseButton(context, plan, state, isProcessing),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanHeader(PremiumPlan plan) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            plan.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanDescription(PremiumPlan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        plan.description!,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white70,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildPlanPrice(PremiumPlan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Giá:',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${(plan.price / 1000).toStringAsFixed(0)}.000 VNĐ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.yellowAccent.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanFeatures(PremiumPlan plan) {
    final features = _getFeaturesForPlan(plan.planId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tính năng:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...features.map((feature) => _buildFeatureItem(feature)),
      ],
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton(BuildContext context, PremiumPlan plan, SubscriptionState state, bool isProcessing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : () => _showPurchaseConfirmationDialog(context, plan),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.amber.withOpacity(0.5),
        ),
        child: isProcessing
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Mua ngay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Utility methods
  PremiumPlan _getUnknownPlan() {
    return PremiumPlan(
      planId: 'unknown',
      name: 'Gói không xác định',
      description: 'Thông tin gói này không có sẵn.',
      price: 0.0,
      durationDays: 0,
      isActive: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<String> _getFeaturesForPlan(String planId) {
    switch (planId) {
      case 'premium_1':
        return [
          'Truy cập 5 sách mỗi tháng',
          'Không quảng cáo',
          'Hỗ trợ cơ bản',
          'Giao diện thân thiện',
        ];
      case 'premium_2':
        return [
          'Truy cập không giới hạn',
          'Không quảng cáo',
          'Hỗ trợ ưu tiên',
          'Đọc ngoại tuyến',
          'Tốc độ tải nhanh',
        ];
      case 'premium_3':
        return [
          'Tất cả tính năng Premium',
          'Tiết kiệm 20% chi phí',
          'Quà tặng độc quyền',
          'Ưu tiên cập nhật',
          'Hỗ trợ VIP 24/7',
        ];
      default:
        return ['Tính năng cơ bản'];
    }
  }

  void _showManageSubscriptionOptions(BuildContext context, UserSubscription subscription, PremiumPlan? currentPlan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Quản lý gói ${currentPlan?.name ?? 'của bạn'}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chọn hành động bạn muốn thực hiện',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                _buildManageOption(
                  context: bc,
                  icon: Icons.cancel_outlined,
                  iconColor: Colors.red,
                  title: 'Hủy gói đăng ký',
                  subtitle: 'Hủy gói hiện tại của bạn',
                  onTap: () {
                    Navigator.pop(bc);
                    _showCancelConfirmationDialog(context);
                  },
                ),
                _buildManageOption(
                  context: bc,
                  icon: Icons.swap_horiz,
                  iconColor: Colors.purple,
                  title: 'Thay đổi gói',
                  subtitle: 'Chọn gói mới phù hợp',
                  onTap: () {
                    Navigator.pop(bc);
                    _showSnackBar(context, 'Vui lòng chọn gói mới trên trang này để thay đổi!', isError: false);
                  },
                ),
                _buildManageOption(
                  context: bc,
                  icon: Icons.history,
                  iconColor: Colors.blue,
                  title: 'Lịch sử giao dịch',
                  subtitle: 'Xem các giao dịch đã thực hiện',
                  onTap: () {
                    Navigator.pop(bc);
                    _showSubscriptionHistoryDialog(context, dummyUserSubscriptions.getRange(0, 1).toList(), dummyPremiumPlans);
                  },
                ),
                _buildManageOption(
                  context: bc,
                  icon: Icons.payment,
                  iconColor: Colors.green,
                  title: 'Quản lý thanh toán',
                  subtitle: 'Cài đặt phương thức thanh toán',
                  onTap: () {
                    Navigator.pop(bc);
                    _showSnackBar(context, 'Tính năng quản lý thanh toán đang được phát triển!', isError: false);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManageOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_outlined,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Xác nhận hủy gói',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn hủy gói đăng ký hiện tại không? Gói của bạn sẽ hết hạn ngay lập tức và bạn sẽ mất quyền truy cập các tính năng Premium.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Không',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Implement cancel subscription logic here
                _showSnackBar(context, 'Đã hủy gói đăng ký thành công!', isError: false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Hủy gói',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSubscriptionHistoryDialog(BuildContext context, List<UserSubscription> history, List<PremiumPlan> availablePlans) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Lịch sử giao dịch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: history.isEmpty
              ? const SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Bạn chưa có giao dịch nào.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
              : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: history.length,
              itemBuilder: (context, index) {
                final sub = history[index];
                final plan = availablePlans.firstWhere(
                      (p) => p.planId == sub.planId,
                  orElse: () => _getUnknownPlan(),
                );
                return _buildHistoryItem(sub, plan);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Đóng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryItem(UserSubscription sub, PremiumPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: sub.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  sub.isActive ? Icons.check_circle : Icons.history,
                  color: sub.isActive ? Colors.green : Colors.grey,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sub.isActive ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sub.isActive ? 'Hoạt động' : 'Hết hạn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Từ: ${sub.startDate.day}/${sub.startDate.month}/${sub.startDate.year}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.event, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Đến: ${sub.endDate.day}/${sub.endDate.month}/${sub.endDate.year}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          if (sub.transactionId != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Mã GD: ${sub.transactionId!.substring(0, 8)}...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showPurchaseConfirmationDialog(BuildContext context, PremiumPlan plan) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Xác nhận mua gói',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gói đăng ký: ${plan.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Giá: ${plan.price.toStringAsFixed(0)} VNĐ',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thời hạn: ${plan.durationDays} ngày',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bạn có chắc muốn mua gói này không?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SubscriptionCubit>().purchasePlan(plan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleStripePayment(BuildContext context, String clientSecret) async {
    try {
      debugPrint('Bắt đầu present Payment Sheet');

      await Stripe.instance.presentPaymentSheet();
      debugPrint('Payment Sheet đã được present thành công');

      if (mounted) {
        context.read<SubscriptionCubit>().handlePaymentResult();
      }
    } on StripeException catch (e) {
      debugPrint('StripeException: ${e.error.code} - ${e.error.message}');

      if (!mounted) return;

      if (e.error.code == FailureCode.Canceled) {
        context.read<SubscriptionCubit>().emit(
          context.read<SubscriptionCubit>().state.copyWith(
            status: SubscriptionStatus.loaded,
            errorMessage: 'Thanh toán đã bị hủy.',
          ),
        );
      } else {
        context.read<SubscriptionCubit>().emit(
          context.read<SubscriptionCubit>().state.copyWith(
            status: SubscriptionStatus.paymentFailure,
            errorMessage: 'Lỗi thanh toán: ${e.error.message ?? "Không xác định"}',
          ),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khác: ${e.toString()}');

      if (!mounted) return;

      context.read<SubscriptionCubit>().emit(
        context.read<SubscriptionCubit>().state.copyWith(
          status: SubscriptionStatus.paymentFailure,
          errorMessage: 'Đã xảy ra lỗi không mong muốn: ${e.toString()}',
        ),
      );
    }
  }
}
