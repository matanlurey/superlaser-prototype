import 'package:http/http.dart' as http;
import 'package:jsonut/jsonut.dart';

/// An unofficial API client for <https://admin.starwarsunlimited.com/api>.
final class SwuApiClient {
  /// Creates a new [SwuApiClient] using the provided HTTP client.
  SwuApiClient(this._client);

  static final _endpoint = Uri.https('admin.starwarsunlimited.com', '/api');

  final http.Client _client;

  /// Returns a list of cards for the given [page].
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
    final response = await _client.get(
      url,
      headers: const {
        'accept': 'application/json',
      },
    );
    return CardData.parse(response.body);
  }

  /// Returns a stream of all cards, starting from the given [page].
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

/// Represents a page of cards.
extension type const CardData._(JsonObject _fields) {
  /// Parses the given JSON string into a [CardData].
  factory CardData.parse(String json) {
    return CardData._(JsonObject.parse(json));
  }

  /// The cards on this page.
  List<CardAttributes> get cards {
    final data = _fields['data'].array().cast<JsonObject>();
    return data.map((t) => t['attributes'].object()).toList().cast();
  }

  /// The pagination information for this page.
  CardPagination get pagination {
    return _fields.deepGet(const ['meta', 'pagination']).as();
  }
}

/// Represents the pagination information for a page of cards.
extension type const CardPagination._(JsonObject _fields) {
  /// The current page number.
  int get page => _fields['page'].as();

  /// The number of cards on this page.
  int get pageSize => _fields['pageSize'].as();

  /// The total number of pages.
  int get pageCount => _fields['pageCount'].as();

  /// The total number of cards.
  int get total => _fields['total'].as();
}

/// Represents the attributes of a card.
extension type const CardAttributes._(JsonObject _fields) {
  /// The unique identifier for the card.
  String get cardUid => _fields['cardUid'].as();

  /// The card number.
  int get cardNumber => _fields['cardNumber'].as();

  /// The number of cards in the set.
  int get cardCount => _fields['cardCount'].as();

  /// The title of the card.
  String get title => _fields['title'].as();

  /// The subtitle of the card.
  String? get subTitle => _fields['subtitle'].asOrNull();

  /// The artist of the card's artwork.
  String get artist => _fields['artist'].as();

  /// Whether the card is unique.
  bool get unique => _fields['unique'].as();

  /// The cost of the card.
  int? get cost => _fields['cost'].asOrNull();

  /// The health of the card.
  int? get hp => _fields['hp'].asOrNull();

  /// The power of the card.
  int? get power => _fields['power'].asOrNull();

  /// Whether the art on the front of the card is horizontal.
  bool get artFrontHorizontal => _fields['artFrontHorizontal'].as();

  /// Whether the art on the back of the card is horizontal.
  bool get artBackHorizontal {
    return _fields['artBackHorizontal'].asOrNull() ?? false;
  }

  /// Whether the card is a foil variant.
  bool get hasFoil => _fields['hasFoil'].as();

  /// Whether the card is a hyperspace variant.
  bool get hyperspace => _fields['hyperspace'].as();

  /// Whether the card is a showcase variant.
  bool get showcase => _fields['showcase'].as();

  /// The card's front artwork.
  CardArtAttributes get artFront {
    return _fields.deepGet(const ['artFront', 'data', 'attributes']).as();
  }

  /// The card's back artwork.
  CardArtAttributes? get artBack {
    return _fields.deepGetOrNull(const ['artBack', 'data', 'attributes']).as();
  }

  /// The card's thumbnail artwork.
  CardArtAttributes get artThumbnail {
    return _fields.deepGet(const ['artThumbnail', 'data', 'attributes']).as();
  }

  /// The card's variants.
  CardData? get variants {
    final variants = _fields['variants'].objectOrNull();
    if (variants == null || variants['data'].isNull) {
      return null;
    }
    final result = CardData._(variants);
    return result;
  }

  /// The card this card is a variant of.
  CardData? get variantOf {
    return _fields.deepGet(const ['variantOf']).as();
  }

  /// Whether this card is a variant.
  bool get isVariant {
    return !_fields.deepGet(const ['variantOf', 'data']).isNull;
  }

  /// The card's aspects.
  List<CardAspect> get aspects {
    final data = _fields.deepGet(const ['aspects', 'data']);
    final array = data.arrayOrNull() ?? JsonArray(const []);
    final result = array.map((i) => i.object()['attributes'].object());
    return result.toList().cast();
  }

  /// The card's duplicate aspects.
  List<CardAspect> get aspectDuplicates {
    final data = _fields.deepGet(const ['aspectDuplicates', 'data']);
    final array = data.arrayOrNull() ?? JsonArray(const []);
    final result = array.map((i) => i.object()['attributes'].object());
    return result.toList().cast();
  }

  /// The card's type.
  CardType get type {
    return _fields.deepGet(const ['type', 'data', 'attributes']).as();
  }

  /// The card's second type.
  CardType get type2 {
    return _fields.deepGet(const ['type2', 'data', 'attributes']).as();
  }

  /// The card's traits.
  List<String> get traits {
    final data = _fields.deepGet(const ['traits', 'data']);
    final array = data.arrayOrNull() ?? JsonArray(const []);
    final result = array.map((i) => i.object()['attributes'].object());
    return result.map((i) => i['name'].string()).toList();
  }

  /// The card's arenas.
  List<String> get arenas {
    final data = _fields.deepGet(const ['arenas', 'data']);
    final array = data.arrayOrNull() ?? JsonArray(const []);
    final result = array.map((i) => i.object()['attributes'].object());
    return result.map((i) => i['name'].string()).toList();
  }

  /// The card's rarity.
  CardRarity get rarity {
    return _fields.deepGet(const ['rarity', 'data', 'attributes']).as();
  }

  /// The card's expansion.
  CardExpansion get expansion {
    return _fields.deepGet(const ['expansion', 'data', 'attributes']).as();
  }
}

/// Represents the attributes of a card's artwork.
extension type const CardArtAttributes._(JsonObject _fields) {
  /// The name of the artwork.
  String get name => _fields['name'].as();

  /// The URL of the artwork.
  String get url => _fields['url'].as();

  /// The width of the artwork.
  int get width => _fields['width'].as();

  /// The height of the artwork.
  int get height => _fields['height'].as();

  /// The alternative text for the artwork.
  String get alternativeText => _fields['alternativeText'].as();

  /// The caption for the artwork.
  String? get caption => _fields['caption'].asOrNull();
}

/// Represents the attributes of a card's aspect.
extension type const CardAspect._(JsonObject _fields) {
  /// The name of the aspect.
  String get name => _fields['name'].as();

  /// The description of the aspect.
  String get description => _fields['description'].as();

  /// The color of the aspect.
  String get color => _fields['color'].as();
}

/// Represents the attributes of a card's type.
extension type const CardType._(JsonObject _fields) {
  /// The name of the type.
  String get name => _fields['name'].as();

  /// The sort value of the type.
  int get sortValue => _fields['sortValue'].as();
}

/// Represents the attributes of a card's rarity.
extension type const CardRarity._(JsonObject _fields) {
  /// The name of the rarity.
  String get name => _fields['name'].as();

  /// The character of the rarity.
  String get character => _fields['character'].as();

  /// The color of the rarity.
  String get color => _fields['color'].as();
}

/// Represents the attributes of a card's expansion.
extension type const CardExpansion._(JsonObject _fields) {
  /// The name of the expansion.
  String get name => _fields['name'].as();

  /// The code of the expansion.
  String get code => _fields['code'].as();
}
