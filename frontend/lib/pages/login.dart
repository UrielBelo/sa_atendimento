import 'package:flutter/material.dart';
import 'package:frontend/pages/homepage.dart';
import 'package:frontend/services/login.dart';
import 'package:frontend/util/single_button_click.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginState extends ChangeNotifier {
  BuildContext context;
  LoginState({required this.context});

  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> login() async {
    isLoading = true;
    LoginService loginService = LoginService(
      login: loginController.text,
      password: passwordController.text,
    );

    loginService.getLogin(context).then((loginResult) {
      if (loginResult != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário ${loginController.text} autenticado com sucesso!'),
            backgroundColor: Colors.red,
          ),
        );
        isLoading = false;
        notifyListeners();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const Homepage();
            },
          ),
        );
      }
    });
    notifyListeners();
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return ChangeNotifierProvider(
      create: (context) => LoginState(context: context),
      child: Builder(builder: (context) {
        LoginState loginState = context.watch<LoginState>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sistema de Atendimentos'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Amêndola & Amêndola Software'),
              ),
            ],
            backgroundColor: theme.colorScheme.primary.withAlpha(200),
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          body: Stack(
            children: [
              Row(
                children: [
                  Gap(20),
                  Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(200),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(200),
                          blurRadius: 5.0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: loginState.formKey,
                      child: Column(
                        children: [
                          Gap(16),
                          Text(
                            'Bem-vindo ao Sistema',
                            style: theme.textTheme.titleMedium!.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                icon: Icon(Icons.person),
                                labelText: 'Identificação do Usuário',
                              ),
                              controller: loginState.loginController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe a identificação do usuário';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                icon: Icon(Icons.password_rounded),
                                labelText: 'Senha de acesso',
                              ),
                              controller: loginState.passwordController,
                              maxLength: 64,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe a senha de acesso';
                                }
                                return null;
                              },
                            ),
                          ),
                          Gap(16),
                          ElevatedButton.icon(
                            onPressed: () {
                              SingleButtonClick sbc = SingleButtonClick();
                              if (!sbc.verify('loginButton')) {
                                if (loginState.formKey.currentState!.validate()) {
                                  loginState.login();
                                }
                              }
                            },
                            label: Text('Entrar'),
                            icon: Icon(Icons.login),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            theme.colorScheme.surface,
                            theme.colorScheme.secondaryContainer.withAlpha(50),
                          ],
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/undraw_sign-up_z2ku.svg',
                          height: mediaQuery.size.height * 0.5,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              loginState.isLoading
                  ? Container(
                      width: mediaQuery.size.width,
                      height: mediaQuery.size.height,
                      color: Colors.black54.withAlpha(50),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      }),
    );
  }
}
