import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yomugo_frontend/l10n/app_localizations.dart';

import '../../app/app_theme.dart';
import '../../data/auth_api.dart';

enum AuthTab { login, register }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.onToggleUiLocale});

  final VoidCallback onToggleUiLocale;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _identifier = TextEditingController();
  final _loginPassword = TextEditingController();

  final _authApi = AuthApi();

  AuthTab _tab = AuthTab.register;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  /// Idioma guardado en cuenta (`preferredLocale` API): `es` | `pt`.
  String _accountPreferredLocale = 'es';
  bool _accountLocaleInitialized = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _identifier.dispose();
    _loginPassword.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_accountLocaleInitialized) {
      _accountPreferredLocale =
          _localeForApi(Localizations.localeOf(context));
      _accountLocaleInitialized = true;
    }
  }

  String _localeForApi(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    if (code == 'pt') return 'pt';
    return 'es';
  }

  Future<void> _showApiAlert(String rawBody) {
    final text = _prettyJson(rawBody);
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.authApiResponseTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
  }

  String _prettyJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return raw.isEmpty ? '(vacío)' : raw;
    }
  }

  bool _validateEmail(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim());
  }

  Future<void> _submitRegister() async {
    final l10n = AppLocalizations.of(context)!;
    final username = _username.text.trim();
    final email = _email.text.trim();
    final pass = _password.text;
    final pass2 = _passwordConfirm.text;

    String? err;
    if (username.length < 2) err = l10n.validationUsernameShort;
    else if (!_validateEmail(email)) err = l10n.validationEmailInvalid;
    else if (pass.length < 8) err = l10n.validationPasswordShort;
    else if (pass != pass2) err = l10n.validationPasswordMatch;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    setState(() => _submitting = true);
    try {
      final res = await _authApi.register(
        username: username,
        email: email,
        password: pass,
        preferredLocale: _accountPreferredLocale,
      );
      if (!mounted) return;
      await _showApiAlert(res.body);
    } catch (e) {
      if (!mounted) return;
      await _showApiAlert('{"error": "$e"}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _submitLoginPlaceholder() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.authLoginComingSoon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiLocale = Localizations.localeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 960;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 38, child: _BrandingColumn()),
                      Expanded(
                        flex: 62,
                        child: _FormColumn(
                          tab: _tab,
                          onTabChanged: (t) => setState(() => _tab = t),
                          username: _username,
                          email: _email,
                          password: _password,
                          passwordConfirm: _passwordConfirm,
                          identifier: _identifier,
                          loginPassword: _loginPassword,
                          obscurePassword: _obscurePassword,
                          obscureConfirm: _obscureConfirm,
                          onTogglePassword: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          onToggleConfirm: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          submitting: _submitting,
                          accountPreferredLocale: _accountPreferredLocale,
                          onAccountPreferredLocaleChanged: (v) =>
                              setState(() => _accountPreferredLocale = v),
                          onPrimary: _tab == AuthTab.register
                              ? _submitRegister
                              : _submitLoginPlaceholder,
                        ),
                      ),
                    ],
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BrandingColumn(compact: true),
                      _FormColumn(
                        tab: _tab,
                        onTabChanged: (t) => setState(() => _tab = t),
                        username: _username,
                        email: _email,
                        password: _password,
                        passwordConfirm: _passwordConfirm,
                        identifier: _identifier,
                        loginPassword: _loginPassword,
                        obscurePassword: _obscurePassword,
                        obscureConfirm: _obscureConfirm,
                        onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        onToggleConfirm: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                        submitting: _submitting,
                        accountPreferredLocale: _accountPreferredLocale,
                        onAccountPreferredLocaleChanged: (v) =>
                            setState(() => _accountPreferredLocale = v),
                        onPrimary: _tab == AuthTab.register
                            ? _submitRegister
                            : _submitLoginPlaceholder,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: _UiLocaleRoundButton(
                  localeCode: uiLocale.languageCode.toLowerCase() == 'pt'
                      ? 'pt'
                      : 'es',
                  tooltip: AppLocalizations.of(context)!.authUiLanguageTooltip,
                  onPressed: widget.onToggleUiLocale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UiLocaleRoundButton extends StatelessWidget {
  const _UiLocaleRoundButton({
    required this.localeCode,
    required this.tooltip,
    required this.onPressed,
  });

  /// Idioma de interfaz actual: `es` | `pt` (se muestra en el botón).
  final String localeCode;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final code =
        localeCode.toLowerCase() == 'pt' ? 'PT' : 'ES';
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surfaceInput,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.4,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandingColumn extends StatelessWidget {
  const _BrandingColumn({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pad = EdgeInsets.fromLTRB(
      compact ? 24 : 48,
      compact ? 32 : 48,
      compact ? 24 : 48,
      compact ? 24 : 48,
    );
    return Container(
      color: AppColors.surface,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!compact)
            Positioned(
              right: -40,
              top: 80,
              child: Text(
                '学',
                style: TextStyle(
                  fontSize: 320,
                  height: 1,
                  fontWeight: FontWeight.w200,
                  color: AppColors.kanjiWatermark,
                ),
              ),
            ),
          Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: compact ? 20 : 56),
                Text(
                  l10n.authHeadline,
                  style: TextStyle(
                    fontSize: compact ? 24 : 32,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.authSubheadline,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: compact ? 20 : 36),
                _feature(Icons.chat_bubble_outline_rounded, l10n.authFeatureChatAi),
                const SizedBox(height: 14),
                _feature(Icons.sports_esports_outlined, l10n.authFeatureMiniGames),
                const SizedBox(height: 14),
                _feature(Icons.insights_outlined, l10n.authFeatureProgress),
                const SizedBox(height: 14),
                _feature(Icons.menu_book_outlined, l10n.authFeatureLessons),
                if (!compact) const Spacer(),
                if (compact) const SizedBox(height: 24),
                Text(
                  l10n.authQuoteJa,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.authQuoteSub,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _FormColumn extends StatelessWidget {
  const _FormColumn({
    required this.tab,
    required this.onTabChanged,
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.identifier,
    required this.loginPassword,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.submitting,
    required this.accountPreferredLocale,
    required this.onAccountPreferredLocaleChanged,
    required this.onPrimary,
  });

  final AuthTab tab;
  final ValueChanged<AuthTab> onTabChanged;
  final TextEditingController username;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController passwordConfirm;
  final TextEditingController identifier;
  final TextEditingController loginPassword;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final bool submitting;
  /// `es` | `pt` — se envía como `preferredLocale` al registrar.
  final String accountPreferredLocale;
  final ValueChanged<String> onAccountPreferredLocaleChanged;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AuthModeToggle(
                tab: tab,
                onChanged: onTabChanged,
              ),
              const SizedBox(height: 36),
              Text(
                tab == AuthTab.register
                    ? l10n.authFormTitleRegister
                    : l10n.authFormTitleLogin,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tab == AuthTab.register
                    ? l10n.authFormSubtitleRegister
                    : l10n.authFormSubtitleLogin,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              if (tab == AuthTab.register) ...[
                _labeledField(
                  label: l10n.authLabelUsername,
                  hint: l10n.authHintUsername,
                  controller: username,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 18),
                _labeledField(
                  label: l10n.authLabelEmail,
                  hint: l10n.authHintEmail,
                  controller: email,
                  icon: Icons.mail_outline_rounded,
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                _labeledField(
                  label: l10n.authLabelPassword,
                  hint: l10n.authHintPassword,
                  controller: password,
                  icon: Icons.lock_outline_rounded,
                  obscure: obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onTogglePassword,
                  ),
                ),
                const SizedBox(height: 18),
                _labeledField(
                  label: l10n.authLabelPasswordConfirm,
                  hint: l10n.authHintPasswordConfirm,
                  controller: passwordConfirm,
                  icon: Icons.lock_outline_rounded,
                  obscure: obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(
                      obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onToggleConfirm,
                  ),
                ),
                const SizedBox(height: 18),
                _accountLanguageSection(context, l10n),
              ] else ...[
                _labeledField(
                  label: l10n.authLabelIdentifier,
                  hint: l10n.authHintIdentifier,
                  controller: identifier,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 18),
                _labeledField(
                  label: l10n.authLabelPassword,
                  hint: l10n.authHintPassword,
                  controller: loginPassword,
                  icon: Icons.lock_outline_rounded,
                  obscure: obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onTogglePassword,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: submitting ? null : onPrimary,
                child: submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tab == AuthTab.register
                                ? l10n.authButtonRegister
                                : l10n.authButtonLogin,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
              if (tab == AuthTab.register) ...[
                const SizedBox(height: 20),
                _legalRow(context, l10n),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceInput,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.authInfoBox,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authLabelAccountLanguage,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.authAccountLanguageDescription,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            backgroundColor: AppColors.surfaceInput,
            foregroundColor: AppColors.textSecondary,
            selectedBackgroundColor: AppColors.accent,
            selectedForegroundColor: Colors.white,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          segments: [
            ButtonSegment<String>(
              value: 'es',
              label: Text(l10n.authAccountLanguageEs),
            ),
            ButtonSegment<String>(
              value: 'pt',
              label: Text(l10n.authAccountLanguagePt),
            ),
          ],
          selected: {accountPreferredLocale},
          onSelectionChanged: (next) {
            if (next.isEmpty) return;
            onAccountPreferredLocaleChanged(next.first);
          },
        ),
      ],
    );
  }

  Widget _labeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }

  Widget _legalRow(BuildContext context, AppLocalizations l10n) {
    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          height: 1.45,
          fontSize: 12,
        ) ??
        const TextStyle(
          color: AppColors.textSecondary,
          height: 1.45,
          fontSize: 12,
        );
    final linkStyle = baseStyle.copyWith(
      color: AppColors.accent,
      fontWeight: FontWeight.w600,
    );
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: l10n.authLegalBeforeTerms),
          TextSpan(
            text: l10n.authTermsOfUse,
            style: linkStyle,
          ),
          TextSpan(text: l10n.authLegalBetweenTermsPrivacy),
          TextSpan(
            text: l10n.authPrivacyPolicy,
            style: linkStyle,
          ),
          TextSpan(text: l10n.authLegalAfter),
        ],
      ),
    );
  }
}

class _AuthModeToggle extends StatelessWidget {
  const _AuthModeToggle({
    required this.tab,
    required this.onChanged,
  });

  final AuthTab tab;
  final ValueChanged<AuthTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleChip(
              label: l10n.authTabLogin,
              selected: tab == AuthTab.login,
              onTap: () => onChanged(AuthTab.login),
            ),
          ),
          Expanded(
            child: _ToggleChip(
              label: l10n.authTabRegister,
              selected: tab == AuthTab.register,
              onTap: () => onChanged(AuthTab.register),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
