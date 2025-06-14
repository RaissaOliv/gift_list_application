import 'package:flutter/material.dart';

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
        useMaterial3: true, // Use Material 3 design
      ),
      home: const LoginPage(),
    );
  }
}

// ===========================================
// Nova Tela de Login (LoginPage)
// ===========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para os campos de texto de email e senha
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Função para simular o processo de login
  void _login() {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    // Simulação de autenticação
    // Em uma aplicação real, você faria uma chamada a uma API aqui.
    if (email == 'testuser' && password == 'testpassword') {
      // Se o login for bem-sucedido, navega para a MyHomePage
      // `pushReplacement` impede que o usuário volte para a tela de login pelo botão de voltar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Lista de Presentes'), // Título atualizado
        ),
      );
    } else {
      // Se o login falhar, mostra um SnackBar (mensagem temporária)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciais inválidas. Tente novamente.'),
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
        backgroundColor: Theme.of(context).colorScheme.primary, // Cor da AppBar
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView( // Permite rolar a tela se o teclado aparecer
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Título da tela de login
              Text(
                'Bem-vindo!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40), // Espaçamento

              // Campo de texto para o Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Digite seu username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person)
                ),
              ),
              const SizedBox(height: 20), // Espaçamento

              // Campo de texto para a Senha
              TextField(
                controller: _passwordController,
                obscureText: true, // Para esconder a senha
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30), // Espaçamento

              // Botão de Login
              ElevatedButton(
                onPressed: _login, // Chama a função _login ao pressionar
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, // Cor do botão
                  foregroundColor: Colors.white, // Cor do texto do botão
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50), // Faz o botão ocupar toda a largura
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Exemplo de botão para "Esqueceu a senha?"
              TextButton(
                onPressed: () {
                  // Ação para "Esqueceu a senha?"
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
// Modelo de Dados para Presente (Gift)
// ===========================================
class Gift {
  final String name;
  final double price;
  final String description;

  Gift({required this.name, required this.price, required this.description});
}

// ===========================================
// Sua Página Inicial (MyHomePage) - Agora Lista de Presentes
// ===========================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Lista de presentes para exibir
  final List<Gift> _giftList = [];

  // Função para navegar para a tela de adicionar presente
  void _navigateToAddGiftPage() async {
    // `await` para esperar o resultado da tela de adicionar presente
    final newGift = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGiftPage()),
    );

    // Se um novo presente for retornado (não nulo), adiciona à lista
    if (newGift != null && newGift is Gift) {
      setState(() {
        _giftList.add(newGift);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _giftList.isEmpty // Verifica se a lista está vazia
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
                          gift.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Preço: R\$ ${gift.price.toStringAsFixed(2)}', // Formata o preço
                          style: Theme.of(context).textTheme.titleMedium,
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
        onPressed: _navigateToAddGiftPage, // Chama a função para adicionar presente
        tooltip: 'Adicionar Presente',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===========================================
// Nova Tela para Adicionar Presente (AddGiftPage)
// ===========================================
class AddGiftPage extends StatefulWidget {
  const AddGiftPage({super.key});

  @override
  State<AddGiftPage> createState() => _AddGiftPageState();
}

class _AddGiftPageState extends State<AddGiftPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Chave global para o formulário, usada para validação
  final _formKey = GlobalKey<FormState>();

  void _saveGift() {
    // Valida o formulário antes de salvar
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final double price = double.tryParse(_priceController.text) ?? 0.0; // Converte para double
      final String description = _descriptionController.text;

      // Cria um novo objeto Gift
      final newGift = Gift(name: name, price: price, description: description);

      // Retorna o novo presente para a tela anterior
      Navigator.pop(context, newGift);
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
          key: _formKey, // Atribui a chave ao formulário
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os elementos
            children: <Widget>[
              // Campo para o Nome do Presente
              TextFormField(
                controller: _nameController,
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

              // Campo para o Preço
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true), // Permite números e decimais
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

              // Campo para a Descrição
              TextFormField(
                controller: _descriptionController,
                maxLines: 3, // Permite múltiplas linhas
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

              // Botão Salvar
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
