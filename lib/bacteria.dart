import 'dart:core';

import 'dart:math';

import 'main.dart';
import 'dart:developer' as debug;

class Bacteria {
  List? vector;
  double? cost;
  double? fitness;
  double? sum_nutrients;
  double? inter;

  double get Cost => cost!;

  double get Inter => inter!;

  double get Fitness => fitness!;

  double get Sum_nutrients => sum_nutrients!;

  set Sum_nutrients(double Sum_nutrients) {
    sum_nutrients = Sum_nutrients;
  }

  set Fitness(Fitness) {
    fitness = Fitness;
  }

  set Inter(double Inter) {
    inter = Inter;
  }

  set Cost(double Cost) {
    cost = Cost;
  }

  // List vector
  // {
  //     get => vector;
  //     set => vector = value;
  // }

  // double Cost
  // {
  //     get => cost;
  //     set => cost = value;
  // }

  // double Fitness
  // {
  //     get => fitness;
  //     set => fitness = value;
  // }

  // double Sum_nutrients
  // {
  //     get => sum_nutrients;
  //     set => sum_nutrients = value;
  // }

  // double Inter
  // {
  //     get => inter;
  //     set => inter = value;
  // }

  Bacteria Clone() {
    dynamic buffer = Bacteria();

    buffer.vector = vector;

    buffer.cost = cost;

    buffer.fitness = fitness;

    buffer.sum_nutrients = sum_nutrients;

    buffer.inter = inter;

    return buffer;
  }
}

class BacteriaCalculate {
  int p = 5;

  List<double> Min = [-2, -2];
  List<double> Max = [2, 2];

  int p_m = 50; //Количество бактерий в популяции

  double p_Ci = 0.1; // Размер шага

  int p_Ned = 1; // Число событий вида "уничтожение - рассеяние"

  int p_Nre = 4; // Число поколений в популяции

  int p_Nc = 70; // Время жизни бактерии

  int p_Ns = 4; // Максимальное число шагов вдоль выбранного направления

  double p_Ped =
      0.25; // Вероятность того, что бактерия будет уничтожена или ее положение будет изменено

  // Параметры для моделирования колонии бактерий
  double d_attr = 0.1;

  double w_attr = 0.2;

  double h_rep = 0.1;

  int w_rep = 10;

  // Не знаю зачем я их добавил, т.к по сути это константы и по ним выбирается рандомное направление
  double generate_random_direction_min = -1.0;

  double generate_random_direction_max = 1.0;

  int size = 2;

  //private List<Vec> m_points;

  int m_p = 0;
  int m_k = 0;

  List<double> RandomVecInD(List<double> min, List<double> max,
      {int? problem_size}) {
    List<double> v = List.filled(2, 0);

    for (int i = 0; i < problem_size!; i++) {
      v[i] = (Random().nextDouble() * (max[i] - min[i]) + max[i]);
    }

    return v;
  }

  List<double>? generate_random_direction(int problem_size) {
    List<double> min = List.filled(problem_size, 0);
    List<double> max = List.filled(problem_size, 0);

    for (int i = 0; i < problem_size; i++) {
      min[i] = generate_random_direction_min;
      max[i] = generate_random_direction_max;
    }

    return RandomVecInD(min, max, problem_size: problem_size);
  }

  double compute_cell_interaction(
      Bacteria cell, List<Bacteria> cells, double d, double w) {
    double sum = 0.0;

    for (int i = 0; i < cells.length; i++) {
      double diff = 0.0;

      for (int k = 0; k < size; k++) {
        diff += pow((cell.vector![k] - cells[i].vector![k]), 2.0);
      }
      sum += d * exp(w * diff);
    }

    return sum;
  }

  // Функция "притягивания - отталкивания"
  double attract_repel(Bacteria cell, List<Bacteria> cells, double d_attr,
      double w_attr, double h_rep, int w_rep) {
    double attract = compute_cell_interaction(cell, cells, -d_attr, -w_attr);
    double repel =
        compute_cell_interaction(cell, cells, h_rep, -w_rep.toDouble());

    return attract + repel;
  }

  // Функция "оценивания" клетки
  void evaluate(Bacteria cell, List<Bacteria> cells, double d_attr,
      double w_attr, double h_rep, int w_rep) {

    cell.Cost = f.calc(x: cell.vector![0], y: cell.vector![1]);
    cell.Inter = attract_repel(cell, cells, d_attr, w_attr, h_rep, w_rep);
    cell.Fitness = cell.Cost + cell.Inter;
  }

  List<double> tumble_cell(
      List<List<double>> search_space, Bacteria cell, double step_size) {
    List<double> step = [];

    step = generate_random_direction(search_space[0].length)!;

    List<double> vector = [search_space[0].length.toDouble()];

    for (int i = 0; i < vector.length; i++) {
      vector[i] = cell.vector![i] + step_size * step[i];

      if (vector[i] < search_space[i][0]) vector[i] = search_space[i][0];
      if (vector[i] > search_space[i][1]) vector[i] = search_space[i][1];
    }

    return vector;
  }

  // Функция расчёта жизненого цикла клетки
  Bacteria chemotaxis(
      List<Bacteria> cells,
      List<List<double>> search_space,
      int chem_steps,
      int swim_length,
      double step_size,
      double d_attr,
      double w_attr,
      double h_rep,
      int w_rep) {
    Bacteria best = Bacteria();
    best = cells[0];
    // cells.forEach((element) {
    //   debug.log('${element.vector}');
    // });

    for (int j = 0; j < chem_steps; j++) {
      List<Bacteria> moved_cells = [];
      // int count = 0;

        // count++;
        // debug.log('${element.vector} ${count}');
      cells.forEach((element) {
        evaluate(element, cells, d_attr, w_attr, h_rep, w_rep);
        double sum_nutrients = 0.0;
        if (best == null || element.Cost < best.Cost) best = element.Clone();
        sum_nutrients += element.Fitness;
        for (int m = 0; m < swim_length; m++) {
          Bacteria new_cell = Bacteria();
          new_cell.vector = (tumble_cell(search_space, element, step_size));
          evaluate(element, cells, d_attr, w_attr, h_rep, w_rep);
          if (element.Cost < best.Cost)
            if (new_cell.Fitness >
              element.Fitness) break;
          element = new_cell;

          sum_nutrients += element.Fitness;
        }
        element.Sum_nutrients = sum_nutrients;
        moved_cells.add(element.Clone());
      });

      // });
      // for (int i = 0; i < cells.length; i++) {
      //   double sum_nutrients = 0.0;
      //
      //   evaluate(cells[i], cells, d_attr, w_attr, h_rep, w_rep);
      //
      //   if (best == null || cells[i].Cost < best.Cost) best = cells[i].Clone();
      //
      //   sum_nutrients += cells[i].Fitness;
      //
      //   for (int m = 0; m < swim_length; m++) {
      //     Bacteria new_cell = Bacteria();
      //     new_cell.vector = (tumble_cell(search_space, cells[i], step_size));
      //
      //     evaluate(new_cell, cells, d_attr, w_attr, h_rep, w_rep);
      //
      //     if (cells[i].Cost < best.Cost) if (new_cell.Fitness >
      //         cells[i].Fitness) break;
      //     cells[i] = new_cell;
      //
      //     sum_nutrients += cells[i].Fitness;
      //   }
      //
      //   cells[i].Sum_nutrients = sum_nutrients;
      //   moved_cells.add(cells[i].Clone());
      // }

      best.vector!.add(best.Cost);

      // arr_temp.Add(best.vector);
      print("${best.vector}");
      // TakeFrame(false);

      cells = moved_cells;
    }

    return best;
  }

  // Функция поиска лучшей клетки
  Bacteria search(
      List<List<double>> search_space,
      int pop_size,
      int elim_disp_steps,
      int repro_steps,
      int chem_steps,
      int swim_length,
      double step_size,
      double d_attr,
      double w_attr,
      double h_rep,
      int w_rep,
      double p_eliminate) {
    List<Bacteria> cells = [];

    List<double> min = List.filled(2, 0);
    List<double> max = List.filled(2, 0);

    for (int i = 0; i < pop_size; i++) {
      Bacteria buff = Bacteria();
      buff.vector = RandomVecInD(Min, Max, problem_size: 2);
      cells.add(buff.Clone());
    }
    // cells.forEach((element) {
    //   debug.log('${element.vector}', name: 'Debug1');
    // });


    Bacteria best = Bacteria();
    Bacteria c_best = Bacteria();
    List<Bacteria> cells_new = [];
    best = cells[0];

    for (int l = 0; l < elim_disp_steps; l++) {
      for (int k = 0; k < repro_steps; k++) {
        c_best = chemotaxis(cells, search_space, chem_steps, swim_length,
            step_size, d_attr, w_attr, h_rep, w_rep);

        if (best == null || c_best.Cost < best.Cost) best = c_best;

        best.vector!.add(best.Cost);
        // buff_min.add(best.vector);
        print("${best.vector}");
        // TakeFrame(true);

        cells.sort((b1, b2) => b1.Sum_nutrients.compareTo(b2.Sum_nutrients));

        for (int i = pop_size ~/ 2; i < pop_size; i++) {
          cells[i] = cells[i - pop_size ~/ 2];
        }
      }

      for (int i = 0; i < search_space[0].length; i++) {
        min[i] = search_space[i][0];
        max[i] = search_space[i][1];
      }

      for (int i = 0; i < cells.length; i++) {
        if (Random().nextDouble() <= p_eliminate)
          cells[i].vector = RandomVecInD(min, max);
      }
    }

    return best;
  }

  void Start() {
    m_p = 0;
    m_k = 0;

    List m_result = [];
    List best_bacteria = [];
    //Конфигурация проблемы
    int problem_size = 2;
    List<List<double>> search_space = [
      [0, 0],
      [0, 0]
    ];
    for (int i = 0, j = 0; i < problem_size && j < 2; i++, j++) {
      search_space[i][0] = Min[j];
      search_space[i][1] = Max[j];
    }
    //конфигурация алгоритма
    int pop_size = p_m;
    double step_size = p_Ci;
    int elim_disp_steps = p_Ned;
    int repro_steps = p_Nre;
    int chem_steps = p_Nc;
    int swim_length = p_Ns;
    double p_eliminate = p_Ped;

    List<List<double>> vector = [];

    Bacteria best = search(
        search_space,
        pop_size,
        elim_disp_steps,
        repro_steps,
        chem_steps,
        swim_length,
        step_size,
        d_attr,
        w_attr,
        h_rep,
        w_rep,
        p_eliminate);
    m_result = best.vector!;

    best_bacteria.add(m_result);
    print("${m_result}");
  }
}

