import 'package:http/http.dart' as http;
import 'package:jsonut/jsonut.dart';

/// An unofficial API client for <https://admin.starwarsunlimited.com/api>.
final class SwuApiClient {
  static final _endpoint = Uri.https('admin.starwarsunlimited.com', '/api');

  final http.Client _client;

  SwuApiClient(this._client);

  Future<CardData> fetchCardsByPage({
    required int page,
    int pageSize = 50,
  }) async {
    if (page < 1) {
      throw RangeError.value(page, 'page', 'must be greater than 0');
    }
    if (pageSize < 1) {
      throw RangeError.value(pageSize, 'pageSize', 'must be greater than 0');
    }
    final url = _endpoint.replace(
      path: '${_endpoint.path}/cards',
      queryParameters: {
        'locale': 'en',
        'sort[0]': 'type.sortValue:asc,cardNumber:asc',
        'pagination[page]': '$page',
        'pagination[pageSize]': '$pageSize',
      },
    );
    final response = await _client.get(url, headers: const {
      'accept': 'application/json',
    });
    return CardData.parse(response.body);
  }

  Stream<CardData> fetchAllCards({
    int page = 1,
  }) async* {
    if (page < 1) {
      throw RangeError.value(page, 'page', 'must be greater than 0');
    }
    while (true) {
      final data = await fetchCardsByPage(page: page);
      yield data;
      if (data.pagination.pageCount <= page) {
        break;
      }
      page++;
    }
  }
}

extension type const CardData._(JsonObject _fields) {
  factory CardData.parse(String json) {
    return CardData._(JsonObject.parse(json));
  }

  List<CardAttributes> get cards {
    final data = _fields['data'].array().cast<JsonObject>();
    return data.map((t) => t['attributes'].object()).toList().cast();
  }

  CardPagination get pagination {
    return _fields.deepGet(const ['meta', 'pagination']).as();
  }
}

extension type const CardPagination._(JsonObject _fields) {
  int get page => _fields['page'].as();
  int get pageSize => _fields['pageSize'].as();
  int get pageCount => _fields['pageCount'].as();
  int get total => _fields['total'].as();
}

extension type const CardAttributes._(JsonObject _fields) {
  String get cardUid => _fields['cardUid'].as();

  int get cardNumber => _fields['cardNumber'].as();
  int get cardCount => _fields['cardCount'].as();

  String get title => _fields['title'].as();
  String? get subTitle => _fields['subtitle'].asOrNull();
  String get artist => _fields['artist'].as();
  bool get unique => _fields['unique'].as();

  int? get cost => _fields['cost'].asOrNull();
  int? get hp => _fields['hp'].asOrNull();
  int? get power => _fields['power'].asOrNull();

  bool get artFrontHorizontal => _fields['artFrontHorizontal'].as();
  bool get artBackHorizontal {
    return _fields['artBackHorizontal'].asOrNull() ?? false;
  }

  bool get hasFoil => _fields['hasFoil'].as();
  bool get hyperspace => _fields['hyperspace'].as();
  bool get showcase => _fields['showcase'].as();

  CardArtAttributes get artFront {
    return _fields.deepGet(const ['artFront', 'data', 'attributes']).as();
  }

  CardArtAttributes? get artBack {
    return _fields.deepGetOrNull(const ['artBack', 'data', 'attributes']).as();
  }

  CardArtAttributes get artThumbnail {
    return _fields.deepGet(const ['artThumbnail', 'data', 'attributes']).as();
  }

  CardData? get variants {
    return _fields.deepGet(const ['variants', 'data']).as();
  }

  CardData? get variantOf {
    return _fields.deepGet(const ['variantOf', 'data']).as();
  }

  bool get isVariant => variantOf != null;

  List<CardAspect> get aspects {
    final data = _fields.deepGet(const ['aspects', 'data']);
    final array = data.arrayOrNull() ?? JsonArray(const []);
    final result = array.map((i) => i.object()['attributes'].object());
    return result.toList().cast();
  }

  List<CardAspect> get aspectDuplicates {
    final data = _fields.deepGet(const ['aspectDuplicates', 'data']);
    final array = data.arrayOrNull() ?? JsonArray(const []);
    final result = array.map((i) => i.object()['attributes'].object());
    return result.toList().cast();
  }

  CardType get type {
    return _fields.deepGet(const ['type', 'data', 'attributes']).as();
  }

  CardType get type2 {
    return _fields.deepGet(const ['type2', 'data', 'attributes']).as();
  }

  List<String> get traits {
    final data = _fields.deepGet(const ['traits', 'data']);
    final array = data.arrayOrNull() ?? JsonArray(const []);
    final result = array.map((i) => i.object()['attributes'].object());
    return result.map((i) => i['name'].string()).toList();
  }

  List<String> get arenas {
    final data = _fields.deepGet(const ['arenas', 'data']);
    final array = data.arrayOrNull() ?? JsonArray(const []);
    final result = array.map((i) => i.object()['attributes'].object());
    return result.map((i) => i['name'].string()).toList();
  }

  CardRarity get rarity {
    return _fields.deepGet(const ['rarity', 'data', 'attributes']).as();
  }

  CardExpansion get expansion {
    return _fields.deepGet(const ['expansion', 'data', 'attributes']).as();
  }
}

extension type const CardArtAttributes._(JsonObject _fields) {
  String get name => _fields['name'].as();
  String get url => _fields['url'].as();

  int get width => _fields['width'].as();
  int get height => _fields['height'].as();

  String get alternativeText => _fields['alternativeText'].as();
  String? get caption => _fields['caption'].asOrNull();
}

extension type const CardAspect._(JsonObject _fields) {
  String get name => _fields['name'].as();
  String get description => _fields['description'].as();
  String get color => _fields['color'].as();
}

extension type const CardType._(JsonObject _fields) {
  String get name => _fields['name'].as();
  int get sortValue => _fields['sortValue'].as();
}

extension type const CardRarity._(JsonObject _fields) {
  String get name => _fields['name'].as();
  String get character => _fields['character'].as();
  String get color => _fields['color'].as();
}

extension type const CardExpansion._(JsonObject _fields) {
  String get name => _fields['name'].as();
  String get code => _fields['code'].as();
}
