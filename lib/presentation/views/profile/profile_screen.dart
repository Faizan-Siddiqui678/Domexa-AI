import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/constants/color_constants.dart';
import '../../../data/models/project_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _editMode   = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProfileViewModel>();
      vm.loadProfile().then((_) {
        if (vm.user != null) {
          _nameCtrl.text  = vm.user!.displayName ?? '';
          _phoneCtrl.text = vm.user!.phone ?? '';
        }
      });
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
          ),
        ),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('My Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('Account & project history', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        actions: [
          Consumer<ProfileViewModel>(builder: (_, vm, __) => TextButton(
            onPressed: () {
              if (_editMode) {
                vm.updateProfile(
                  displayName: _nameCtrl.text.trim(),
                  phone: _phoneCtrl.text.trim(),
                );
              }
              setState(() => _editMode = !_editMode);
            },
            child: Text(_editMode ? 'Save' : 'Edit',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          )),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Projects'),
          ],
        ),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (ctx, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _buildProfileTab(vm),
              _buildProjectsTab(vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTab(ProfileViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 12),
        if (vm.successMessage != null) _buildBanner(vm.successMessage!, true, vm),
        if (vm.errorMessage != null)   _buildBanner(vm.errorMessage!, false, vm),
        _buildAvatar(vm),
        const SizedBox(height: 28),
        _buildInfoCard(vm),
        const SizedBox(height: 24),
        _buildSignOutButton(),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildAvatar(ProfileViewModel vm) {
    final name = vm.user?.displayName ?? 'U';
    return Column(children: [
      Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
            gradient: AppColors.primaryGradient, shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow),
        child: Center(child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white),
        )),
      ),
      const SizedBox(height: 14),
      Text(vm.user?.displayName ?? 'User',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text(vm.user?.email ?? '',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
            color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
        child: Text('${vm.projects.length} Projects',
            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
      ),
    ]);
  }

  Widget _buildInfoCard(ProfileViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Account Information',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        _buildField('Full Name', _nameCtrl, Icons.person_outlined, _editMode),
        const SizedBox(height: 12),
        _buildField('Phone', _phoneCtrl, Icons.phone_outlined, _editMode),
        const SizedBox(height: 12),
        _buildReadonlyField('Email', vm.user?.email ?? '', Icons.email_outlined),
        const SizedBox(height: 12),
        _buildReadonlyField('Member Since',
            vm.user?.createdAt != null
                ? _formatDate(vm.user!.createdAt!)
                : 'N/A',
            Icons.calendar_today_outlined),
      ]),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, bool enabled) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        enabled: enabled,
        style: TextStyle(fontSize: 14,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
          filled: true,
          fillColor: enabled ? AppColors.bgInput : AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        ),
      ),
    ]);
  }

  Widget _buildReadonlyField(String label, String value, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
            color: AppColors.background, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ]),
      ),
    ]);
  }

  Widget _buildSignOutButton() {
    return Consumer<AuthViewModel>(builder: (ctx, authVm, _) => GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: ctx,
          builder: (_) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sign Out', style: TextStyle(color: AppColors.error))),
            ],
          ),
        );
        if (confirm == true) {
          await authVm.signOut();
          if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        }
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
            color: AppColors.errorLight, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout, color: AppColors.error, size: 20),
          SizedBox(width: 10),
          Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
      ),
    ));
  }

  Widget _buildProjectsTab(ProfileViewModel vm) {
    if (vm.projects.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
            child: const Icon(Icons.folder_open_outlined, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('No Projects Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Your saved house plans will appear here',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: vm.projects.length,
      itemBuilder: (ctx, i) => _buildProjectCard(vm, vm.projects[i]),
    );
  }

  Widget _buildProjectCard(ProfileViewModel vm, ProjectModel project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(project.projectName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: () => _confirmDelete(vm, project),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: AppColors.errorLight, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline, color: AppColors.error, size: 16),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _chip('${project.plotArea.toInt()} sqft', Icons.straighten_outlined),
          _chip('${project.numFloors} Floor${project.numFloors > 1 ? "s" : ""}', Icons.layers_outlined),
          _chip('${project.bedrooms} BR', Icons.bed_outlined),
          _chip(project.budgetRange.toUpperCase(), Icons.monetization_on_outlined),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('PKR ${_fmt(project.totalCost)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
          Text(_formatDate(project.createdAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ]),
      ]),
    );
  }

  Widget _chip(String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
        color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.primary),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _buildBanner(String msg, bool isSuccess, ProfileViewModel vm) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: isSuccess ? AppColors.successLight : AppColors.errorLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.3))),
        child: Row(children: [
          Icon(isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: isSuccess ? AppColors.success : AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg,
              style: TextStyle(color: isSuccess ? AppColors.success : AppColors.error, fontSize: 13))),
          GestureDetector(
            onTap: vm.clearMessages,
            child: Icon(Icons.close,
                color: isSuccess ? AppColors.success : AppColors.error, size: 16),
          ),
        ]),
      );

  Future<void> _confirmDelete(ProfileViewModel vm, ProjectModel project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Delete "${project.projectName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) vm.deleteProject(project.id);
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _fmt(double cost) {
    if (cost >= 10000000) return '${(cost / 10000000).toStringAsFixed(1)} Cr';
    if (cost >= 100000)   return '${(cost / 100000).toStringAsFixed(1)} Lac';
    return cost.toStringAsFixed(0);
  }
}