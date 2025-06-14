import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ===========================================
// LOGIN
// ===========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // URL base da API. Como estamos rodando o app por emulador Android, usamos 10.0.2.2
  final String _baseUrl = 'http://10.0.2.2:5500'; 

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'), 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      // Verifica se o widget ainda está montado antes de usar o context
      if (!mounted) return;

      if (response.statusCode == 200) {
        // Se o login for bem-sucedido, extrai o token de acesso
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String accessToken = responseData['access_token'];
        print('Login bem-sucedido! Token: $accessToken');

        // Navega para a MyHomePage, passando o token de acesso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
              title: 'Lista de Presentes',
              accessToken: accessToken,
            ),
          ),
        );
      } else if (response.statusCode == 401) {
        print('Erro 401: Credenciais inválidas.'); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciais inválidas. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Outros erros de resposta da API
        print('Erro ao fazer login. Status Code: ${response.statusCode}, Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer login: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
    
      if (!mounted) return;
      print('Exceção de conexão ao fazer login: $e'); // Log de exceção
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Bem-vindo!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 40),
             
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nome de Usuário',
                  hintText: 'Digite seu nome de usuário',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
            
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              // Botão de Login
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // "Esqueceu a senha" não funcional, mas implementamos como mock :]
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade de recuperação de senha em desenvolvimento.')),
                  );
                },
                child: Text(
                  'Esqueceu a senha?',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================
//GIFT LIST
// ===========================================
class Gift {
  final String nameGift; 
  final double value; 
  final String description;
  final String category;

  Gift({
    required this.nameGift,
    required this.value,
    required this.description,
    required this.category,
  });

  // Factory constructor para criar um objeto Gift a partir de um JSON recebido da API
  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      nameGift: json['name_gift'] as String,
      value: (json['value'] as num).toDouble(), 
      description: json['description'] as String,
      category: json['category'] as String,
    );
  }

  // Método para converter um objeto Gift para um JSON, para enviar à API
  Map<String, dynamic> toJson() {
    return {
      'name_gift': nameGift,
      'value': value,
      'description': description,
      'category': category,
    };
  }
}

// ===========================================
// HOME
// ===========================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.accessToken, //Sem token = redireciona para o login
  });

  final String title;
  final String accessToken;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Gift> _giftList = [];
  bool _isLoading = true; 
  final String _baseUrl = 'http://10.0.2.2:5500';

  @override
  void initState() {
    super.initState();
    _fetchGifts(); // Carrega os presentes da API ao iniciar a tela, gerenciamento de estado
  }

  
  Future<void> _fetchGifts() async {
    setState(() {
      _isLoading = true; 
    });
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/gifts/'), 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      // Verifica se o widget ainda está montado antes de usar o context
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _giftList = responseData.map((json) => Gift.fromJson(json)).toList();
        });
        print('Presentes carregados com sucesso. Total: ${_giftList.length}'); 
      } else if (response.statusCode == 401) {
        print('Erro 401 ao carregar presentes: Token inválido ou expirado.');
        // Redirecionar para o login se o token for inválido/expirado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão expirada. Por favor, faça login novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
       else if (response.statusCode == 404) {
        setState(() {
          _giftList = [];
        });
        print('Erro 404 ao carregar presentes: Nenhum presente encontrado.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum presente encontrado no servidor.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      else {
        
        print('Erro ao carregar presentes. Status Code: ${response.statusCode}, Body: ${response.body}'); // Log de outros erros
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar presentes: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('Exceção de conexão ao carregar presentes: $e'); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão ao carregar presentes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  void _navigateToAddGiftPage() async {
    // Navega para a tela de adicionar presente, passando o token de acesso
    final bool? giftAdded = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddGiftPage(accessToken: widget.accessToken)),
    );

    if (!mounted) return;

    // Se um presente foi adicionado com sucesso (retornado true de AddGiftPage), recarrega a lista
    if (giftAdded != null && giftAdded) {
      _fetchGifts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : _giftList.isEmpty // Se a lista estiver vazia após o carregamento
              ? const Center(
                  child: Text(
                    'Nenhum presente adicionado ainda. Adicione um!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _giftList.length,
                  itemBuilder: (context, index) {
                    final gift = _giftList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gift.nameGift,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Preço: R\$ ${gift.value.toStringAsFixed(2)}', 
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Categoria: ${gift.category}', 
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              gift.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddGiftPage,
        tooltip: 'Adicionar Presente',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===========================================
//ADD GIFT SCREEN
// ===========================================
class AddGiftPage extends StatefulWidget {
  const AddGiftPage({
    super.key,
    required this.accessToken, 
  });

  final String accessToken;

  @override
  State<AddGiftPage> createState() => _AddGiftPageState();
}

class _AddGiftPageState extends State<AddGiftPage> {
  // Controladores adaptados aos campos da API
  final TextEditingController _nameGiftController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final String _baseUrl = 'http://10.0.2.2:5500'; 

  Future<void> _saveGift() async {
    if (_formKey.currentState!.validate()) {
      final String nameGift = _nameGiftController.text;
      final double value = double.tryParse(_valueController.text) ?? 0.0;
      final String description = _descriptionController.text;
      final String category = _categoryController.text;

      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/api/gifts/'), 
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${widget.accessToken}',
          },
          body: jsonEncode(<String, dynamic>{
            'name_gift': nameGift,
            'value': value,
            'description': description,
            'category': category,
          }),
        );

       
        if (!mounted) return;

        if (response.statusCode == 201) { 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Presente adicionado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          print('Presente adicionado com sucesso! Status Code: ${response.statusCode}'); 
          Navigator.pop(context, true); // Retorna 'true' para a tela anterior (MyHomePage)
        } else if (response.statusCode == 401) {
            // Token inválido/expirado
            print('Erro 401 ao adicionar presente: Token inválido ou expirado.');
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Sessão expirada. Por favor, faça login novamente.'),
                    backgroundColor: Colors.red,
                ),
            );
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        }
        else {
          // Outros erros da API
          print('Erro ao adicionar presente. Status Code: ${response.statusCode}, Body: ${response.body}'); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao adicionar presente: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
           Navigator.pop(context, false); // Retorna 'false' em caso de erro
        }
      } catch (e) {
        
        if (!mounted) return;
        print('Exceção de conexão ao adicionar presente: $e'); // Log de exceção
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de conexão ao adicionar presente: $e'),
            backgroundColor: Colors.red,
          ),
        );
         Navigator.pop(context, false); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Presente', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[


              TextFormField(
                controller: _nameGiftController,
                decoration: InputDecoration(
                  labelText: 'Nome do Presente',
                  hintText: 'Ex: Boneca, Carro, Livro',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.card_giftcard),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do presente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),


              TextFormField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Preço (R\$)',
                  hintText: 'Ex: 99.99',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um número válido para o preço.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),


              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  hintText: 'Ex: Brinquedos, Eletrônicos',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a categoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
             
             

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex: Presente ideal para crianças de 5 anos.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
            
            
            
              ElevatedButton(
                onPressed: _saveGift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Salvar Presente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
