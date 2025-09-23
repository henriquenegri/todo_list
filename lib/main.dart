import 'package:flutter/material.dart';

// Ponto de entrada da aplicação.
void main() {
  runApp(const MyApp());
}

// Definição da classe Tarefa para modelar os dados.
class Tarefa {
  int id;
  String titulo;
  bool concluida;

  Tarefa({required this.id, required this.titulo, this.concluida = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
      ),
      home: const TelaListaTarefas(),
    );
  }
}

// Enum para representar os estados do filtro.
enum FiltroStatus { todas, pendentes, concluidas }

class TelaListaTarefas extends StatefulWidget {
  const TelaListaTarefas({super.key});

  @override
  State<TelaListaTarefas> createState() => _TelaListaTarefasState();
}

class _TelaListaTarefasState extends State<TelaListaTarefas> {
  final List<Tarefa> _tarefas = [];
  FiltroStatus _filtroAtual = FiltroStatus.todas;
  int _proximoId = 1;

  final TextEditingController _textFieldController = TextEditingController();

  List<Tarefa> get _tarefasFiltradas {
    switch (_filtroAtual) {
      case FiltroStatus.pendentes:
        return _tarefas.where((tarefa) => !tarefa.concluida).toList();
      case FiltroStatus.concluidas:
        return _tarefas.where((tarefa) => tarefa.concluida).toList();
      case FiltroStatus.todas:
      default:
        return _tarefas;
    }
  }

  void _adicionarTarefa(String titulo) {
    if (titulo.isNotEmpty) {
      setState(() {
        _tarefas.add(Tarefa(id: _proximoId++, titulo: titulo));
      });
      _textFieldController.clear();
      Navigator.of(context).pop(); // Fecha o diálogo
    }
  }

  void _editarTarefa(Tarefa tarefa, String novoTitulo) {
    if (novoTitulo.isNotEmpty) {
      setState(() {
        tarefa.titulo = novoTitulo;
      });
      _textFieldController.clear();
      Navigator.of(context).pop(); // Fecha o diálogo
    }
  }

  void _removerTarefa(int id) {
    setState(() {
      _tarefas.removeWhere((tarefa) => tarefa.id == id);
    });
  }

  void _marcarComoConcluida(int id, bool? concluida) {
    setState(() {
      final tarefa = _tarefas.firstWhere((t) => t.id == id);
      tarefa.concluida = concluida ?? false;
    });
  }

  // Função para exibir o diálogo de adicionar ou editar tarefa.
  Future<void> _exibirDialogoTarefa({Tarefa? tarefa}) async {
    // Se estiver editando, preenche o campo com o título atual.
    if (tarefa != null) {
      _textFieldController.text = tarefa.titulo;
    } else {
      _textFieldController.clear();
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa'),
          content: TextField(
            controller: _textFieldController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Digite o título da tarefa',
            ),
            onSubmitted: (value) {
              if (tarefa == null) {
                _adicionarTarefa(value);
              } else {
                _editarTarefa(tarefa, value);
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                if (tarefa == null) {
                  _adicionarTarefa(_textFieldController.text);
                } else {
                  _editarTarefa(tarefa, _textFieldController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
        actions: [
          PopupMenuButton<FiltroStatus>(
            icon: const Icon(Icons.filter_list),
            onSelected: (FiltroStatus status) {
              setState(() {
                _filtroAtual = status;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<FiltroStatus>>[
                  const PopupMenuItem<FiltroStatus>(
                    value: FiltroStatus.todas,
                    child: Text('Todas'),
                  ),
                  const PopupMenuItem<FiltroStatus>(
                    value: FiltroStatus.pendentes,
                    child: Text('Pendentes'),
                  ),
                  const PopupMenuItem<FiltroStatus>(
                    value: FiltroStatus.concluidas,
                    child: Text('Concluídas'),
                  ),
                ],
          ),
        ],
      ),
      body: _tarefasFiltradas.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma tarefa encontrada.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _tarefasFiltradas.length,
              itemBuilder: (context, index) {
                final tarefa = _tarefasFiltradas[index];
                return ListTile(
                  leading: Checkbox(
                    value: tarefa.concluida,
                    onChanged: (bool? value) {
                      _marcarComoConcluida(tarefa.id, value);
                    },
                  ),
                  title: Text(
                    tarefa.titulo,
                    style: TextStyle(
                      decoration: tarefa.concluida
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _exibirDialogoTarefa(tarefa: tarefa),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removerTarefa(tarefa.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _exibirDialogoTarefa(),
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}
