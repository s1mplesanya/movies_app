// ignore_for_file: public_member_api_docs, sort_constructors_first
class PaginatorLoadResult<T> {
  final List<T> data;
  final int currentPage;
  final int totalPage;

  PaginatorLoadResult({
    required this.data,
    required this.currentPage,
    required this.totalPage,
  });
}

typedef PaginatorLoad<T> = Future<PaginatorLoadResult<T>> Function(int);

class Paginator<T> {
  final _data = <T>[];

  late int _currentPage;
  late int _totalPage;
  var _isLoadingInProgress = false;
  final PaginatorLoad<T> load;
  Paginator(this.load);

  List<T> get data => _data;

  Future<void> resetList() async {
    _currentPage = 0;
    _totalPage = 1;
    _data.clear();
    await loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (_isLoadingInProgress || _currentPage >= _totalPage) return;
    _isLoadingInProgress = true;
    final nextPage = _currentPage + 1;
    try {
      final result = await load(nextPage);
      _currentPage = result.currentPage;
      _totalPage = result.totalPage;
      _data.addAll(result.data);

      _isLoadingInProgress = false;
    } catch (e) {
      _isLoadingInProgress = false;
    }
  }
}
