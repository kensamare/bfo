import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class cFunction{
  final String function;
  cFunction({required this.function});

  double calc({required double x, double? y}){
    Parser p = Parser();
    Expression exp = p.parse(this.function);
    ContextModel ctx = ContextModel();
    Variable x1 = Variable('x');
    ctx.bindVariable(x1, Number(x));
    Variable pi = Variable('pi');
    ctx.bindVariable(pi, Number(math.pi));
    Variable e = Variable('e');
    ctx.bindVariable(e, Number(math.e));
    if(y != null){
      Variable y1 = Variable('y');
      ctx.bindVariable(y1, Number(y));
    }
    double evl = exp.evaluate(EvaluationType.REAL, ctx);
    // print(evl);
    return evl;
  }
}