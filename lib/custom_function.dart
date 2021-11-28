import 'package:math_expressions/math_expressions.dart';

class cFunction{
  final String function;
  cFunction({required this.function});

  double calc({required double x, double? y}){
    Parser p = Parser();
    Expression exp = p.parse(this.function);
    ContextModel ctx = ContextModel();
    Variable x1 = Variable('x');
    ctx.bindVariable(x1, Number(x));
    if(y != null){
      Variable y1 = Variable('y');
      ctx.bindVariable(y1, Number(y));
    }
    double evl = exp.evaluate(EvaluationType.REAL, ctx);
    // print(evl);
    return evl;
  }
}