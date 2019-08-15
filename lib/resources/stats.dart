import 'package:bezier_chart/bezier_chart.dart';
import 'package:igflexin/model/resource.dart';
import 'package:meta/meta.dart';

enum StatsState { None, Pending, Some }

class StatsResource extends Resource<StatsState, List<DataPoint<DateTime>>> {
  StatsResource({@required StatsState state, List<DataPoint<DateTime>> data})
      : super(state: state, data: data);
}
