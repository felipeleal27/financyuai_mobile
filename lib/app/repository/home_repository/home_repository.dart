
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/data/model/categoria_model.dart';

abstract class HomeRepository {
  Future<List<MovimentacaoModel>> getMovimentacoes(int mesAtual);
  Future<List<CategoriaModel>> getCategorias();
  Future<bool> inserirCategoria(CategoriaModel categoria);
  Future<bool> atualizarCategoria(CategoriaModel categoria);
  Future<bool> removerCategoria(int id);
  Future<bool> novaMovimentacao(MovimentacaoModel movimentacao);
  Future<bool> removerMovimentacao(MovimentacaoModel movimentacao);
  Future<double> setSaldo(double value, bool removendo);
  Future<void> syncCategoriasToFirebase();
  Future<void> syncMovimentacoesToFirebase();
}
