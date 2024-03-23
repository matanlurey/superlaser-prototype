/// [Star Wars: Unlimited][] data models and primitives.
///
/// The features defined in this library are the core building blocks for
/// interacting with common game concepts such as [Card]s, [Expansion]s, and
/// card components such as [Trait]s and [Aspect]s.
///
/// [star wars: unlimited]: https://starwarsunlimited.com/
///
/// ## Usage
///
/// ```dart
/// import 'package:unlimited/core.dart';
/// ```
library core;

// Imported for documentation purposes.
import 'package:unlimited/core.dart';

export 'src/core/arena.dart' show Arena;
export 'src/core/aspect.dart' show Aspect, Aspects;
export 'src/core/card.dart'
    show
        ArenaCard,
        AttachmentCard,
        BaseCard,
        Card,
        CardReference,
        DeckCard,
        EventCard,
        LeaderCard,
        LeaderUnitCard,
        TargetCard,
        TokenCard,
        UnitCard,
        UpgradeCard;
export 'src/core/catalog.dart' show Catalog, CatalogExpansion;
export 'src/core/expansion.dart'
    show Expansion, ReleasedExpansion, UnreleasedExpansion;
export 'src/core/rarity.dart' show Rarity;
export 'src/core/trait.dart' show Trait;
export 'src/core/variant.dart'
    show CanonicalCard, CardOrVariant, VariantCard, VariantType;
