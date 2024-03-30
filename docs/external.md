# External Tools

A list of external resources and tools to consider interopability with.

- [forcetable.com](#forcetablecom)
- [limitlesstcg.com](#limitlesstcgcom)
- [garbagerollers.com](#garbagerollerscom)
- [starwarsunlimited.com](#starwarsunlimitedcom)
- [swu-db.com](#swu-dbcom)
- [swudb.com](#swudbcom)
- [swuresource.com](#swuresourcecom)
- [sw-unlimited-db.com](#sw-unlimited-dbcom)
- [tcgplayer.com](#tcgplayercom)
- [youtube.com](#youtubecom)

## [forcetable.com](https://forcetable.com/)

Can import decks from a URL schema, for example:

```txt
https://www.forcetable.net/swu/import?svc=swudb&id=ewogICJtZXRhZGF0YSI6IHsKICAgICJuYW1lIjogIkRhcnRoIFZhZGVyIC0gU3RhcnRlciBEZWNrIiwKICAgICJhdXRob3IiOiAiZGVjYWZtYXRhbiIKICB9LAogICJsZWFkZXIiOiB7CiAgICAiaWQiOiAiU09SXzAxMCIsCiAgICAiY291bnQiOiAxCiAgfSwKICAiYmFzZSI6IHsKICAgICJpZCI6ICJTT1JfMDIzIiwKICAgICJjb3VudCI6IDEKICB9LAogICJkZWNrIjogWwogICAgewogICAgICAiaWQiOiAiU09SXzEyMyIsCiAgICAgICJjb3VudCI6IDEKICAgIH0sCiAgICB7CiAgICAgICJpZCI6ICJTT1JfMjI3IiwKICAgICAgImNvdW50IjogMgogICAgfSwKICAgIHsKICAgICAgImlkIjogIlNPUl8yMzMiLAogICAgICAiY291bnQiOiAzCiAgICB9LAogICAgewogICAgICAiaWQiOiAiU09SXzA5MiIsCiAgICAgICJjb3VudCI6IDEKICAgIH0sCiAgICB7CiAgICAgICJpZCI6ICJTT1JfMTcyIiwKICAgICAgImNvdW50IjogMwogICAgfSwKICAgIHsKICAgICAgImlkIjogIlNPUl8yMjkiLAogICAgICAiY291bnQiOiAzCiAgICB9LAogICAgewogICAgICAiaWQiOiAiU09SXzEzNiIsCiAgICAgICJjb3VudCI6IDMKICAgIH0sCiAgICB7CiAgICAgICJpZCI6ICJTT1JfMDg2IiwKICAgICAgImNvdW50IjogMQogICAgfSwKICAgIHsKICAgICAgImlkIjogIlNPUl8wODgiLAogICAgICAiY291bnQiOiAxCiAgICB9LAogICAgewogICAgICAiaWQiOiAiU09SXzEzOSIsCiAgICAgICJjb3VudCI6IDEKICAgIH0sCiAgICB7CiAgICAgICJpZCI6ICJTT1JfMjMwIiwKICAgICAgImNvdW50IjogMQogICAgfSwKICAgIHsKICAgICAgImlkIjogIlNPUl8xMzIiLAogICAgICAiY291bnQiOiAzCiAgICB9LAogICAgewogICAgICAiaWQiOiAiU09SXzA4MyIsCiAgICAgICJjb3VudCI6IDMKICAgIH0sCiAgICB7CiAgICAgICJpZCI6ICJTT1JfMTMwIiwKICAgICAgImNvdW50IjogMgogICAgfSwKICAgIHsKICAgICAgImlkIjogIlNPUl8yMzIiLAogICAgICAiY291bnQiOiAyCiAgICB9LAogICAgewogICAgICAiaWQiOiAiU09SXzIyOCIsCiAgICAgICJjb3VudCI6IDIKICAgIH0sCiAgICB7CiAgICAgICJpZCI6ICJTT1JfMjM0IiwKICAgICAgImNvdW50IjogMQogICAgfSwKICAgIHsKICAgICAgImlkIjogIlNPUl8wODkiLAogICAgICAiY291bnQiOiAxCiAgICB9LAogICAgewogICAgICAiaWQiOiAiU09SXzEzNSIsCiAgICAgICJjb3VudCI6IDEKICAgIH0sCiAgICB7CiAgICAgICJpZCI6ICJTT1JfMTI4IiwKICAgICAgImNvdW50IjogMwogICAgfSwKICAgIHsKICAgICAgImlkIjogIlNPUl8yMjUiLAogICAgICAiY291bnQiOiAyCiAgICB9LAogICAgewogICAgICAiaWQiOiAiU09SXzA4NCIsCiAgICAgICJjb3VudCI6IDMKICAgIH0sCiAgICB7CiAgICAgICJpZCI6ICJTT1JfMjI2IiwKICAgICAgImNvdW50IjogMwogICAgfSwKICAgIHsKICAgICAgImlkIjogIlNPUl8yMzEiLAogICAgICAiY291bnQiOiAxCiAgICB9LAogICAgewogICAgICAiaWQiOiAiU09SXzA3OSIsCiAgICAgICJjb3VudCI6IDEKICAgIH0sCiAgICB7CiAgICAgICJpZCI6ICJTT1JfMTI2IiwKICAgICAgImNvdW50IjogMQogICAgfSwKICAgIHsKICAgICAgImlkIjogIlNPUl8xMjkiLAogICAgICAiY291bnQiOiAxCiAgICB9CiAgXSwKICAic2lkZWJvYXJkIjogW10KfQ==
```

The `id={}` parameter is a base64 encoded string of the popular JSON format.

## [limitlesstcg.com](https://limitlesstcg.com/)

Events and [decklists](https://play.limitlesstcg.com/tournament/swu-launch-event/player/cerberusrex/decklist). Would require more work to parse
as it's not a structured format.

## [garbagerollers.com](https://garbagerollers.com/)

Blog with decks and articles.

## [starwarsunlimited.com](https://starwarsunlimited.com/)

Maintains a [deck builder](https://starwarsunlimited.com/deck-builder), and
an unofficial API [that we scrape](../packages/jawa/lib/src/scavenge.dart).

The deck builder has an option to export as a base64 encoded string, which
appears to be encrypted. For an example, a deck with "Director Krennic",
"Echo Base", and a single "Inferno Four" unit is exported as:

```json
{
  "player": "3651379",
  "name": "Untitled Deck",
  "image": 58,
  "leaders": [
    60
  ],
  "base": 308,
  "resources": [
    {
      "card": 392,
      "cardId": "9133080458",
      "count": 1
    }
  ],
  "sideboard": [],
  "isMultiplayer": false
}
```

... but is server-side encrypted as the following base64 encoded string:

```txt
U2FsdGVkX1/HcZqIP7FrR5uk8xquyPvoqA79BDFxmDLorh5FMzHVErk9bpG9NGJXCoa1D7rbT2C03DZMMrKvK6pU9MI4KLkmz1w9l0C0eM/1sa1rmIPA8WyJDQEM8RKuKJiW/ltRXb1vvvIgfPcF0bo4E3Snna/jZx7Cc6zZAc8=
```

... which in turn is the following string when decoded:

```txt
Salted__Çq\x9A\x88?±kG\x9B¤ó\x1A®Èûè¨\x0Eý\x041q\x982è®\x1EE31Õ\x12¹=n\x91½4bW\n\x86µ\x0FºÛO`´Ü6L2²¯+ªTôÂ8(¹&Ï\\=\x97@´xÏõ±­k\x98\x83Àñl\x89\r\x01\fñ\x12®(\x98\x96þ[Q]½o¾ò |÷\x05Ñº8\x13t§\x9D¯ãg\x1EÂs¬Ù\x01Ï
```

It's likely if we wanted to support importing/exporting decks from this site,
we'd need to either reverse engineer the encryption, or unofficially use their
API directly.

### [swu-db.com](https://swu-db.com/)

Has a [public API](https://www.swu-db.com/api) that we could use if the
"unofficial" nature of scraping the official website becomes a problem.

### [swudb.com](https://swudb.com/)

Confusingly, another website with basically the same name.

Supports exporting decks as a JSON file with the same format as the
[sw-unlimited-db.com](#sw-unlimited-dbcom) website.

Also supports exporting decks as an image, which is a neat feature.

<details>

<summary>Example Image</summary>

![image](https://github.com/matanlurey/swu/assets/168174/83637ac3-1dea-4191-9e48-6227480cb38f)

</details>

There is also a CSV import feature for bulk import:

```csv
Set,CardNumber,Count,IsFoil
SOR,005,3,false
SOR,100,4,true
SOR,123,2,false
SOR,123,3,true
```

### [swuresource.com](https://swuresource.com/)

News and decklists ([example](https://www.swuresource.com/swu-launch-celebration-event/)) from events.

They have an [RSS feed](https://www.swuresource.com/feed/).

### [sw-unlimited-db.com](https://sw-unlimited-db.com/)

Has [decks](https://sw-unlimited-db.com/decks/) and
[collections](https://sw-unlimited-db.com/collection/) with an [intuitive system
for adding booster packs](https://sw-unlimited-db.com/collection/):

![Add a card pack](https://github.com/matanlurey/swu/assets/168174/da0f4459-9664-4e21-b541-4febac6f6d72)

Decks can be exported to a TTS saved object, or Deck Builder JSON.

<details>

<summary>Example JSON</summary>

```json
{
  "leader": {
    "id": "SOR_016",
    "count": 1
  },
  "base": {
    "id": "SOR_020",
    "count": 1
  },
  "deck": [
    {
      "unit": "Unit",
      "id": "SOR_031",
      "count": 3
    },
    {
      "unit": "Unit",
      "id": "SOR_206",
      "count": 3
    },
    {
      "unit": "Unit",
      "id": "SOR_062",
      "count": 2
    },
    {
      "unit": "Upgrade",
      "id": "SOR_072",
      "count": 3
    },
    {
      "unit": "Event",
      "id": "SOR_186",
      "count": 3
    },
    {
      "unit": "Unit",
      "id": "SOR_209",
      "count": 3
    },
    {
      "unit": "Event",
      "id": "SOR_041",
      "count": 3
    },
    {
      "unit": "Event",
      "id": "SOR_221",
      "count": 3
    },
    {
      "unit": "Event",
      "id": "SOR_222",
      "count": 3
    },
    {
      "unit": "Event",
      "id": "SOR_042",
      "count": 3
    },
    {
      "unit": "Event",
      "id": "SOR_077",
      "count": 3
    },
    {
      "unit": "Event",
      "id": "SOR_078",
      "count": 3
    },
    {
      "unit": "Unit",
      "id": "SOR_183",
      "count": 3
    },
    {
      "unit": "Unit",
      "id": "SOR_038",
      "count": 3
    },
    {
      "unit": "Unit",
      "id": "SOR_039",
      "count": 3
    },
    {
      "unit": "Unit",
      "id": "SOR_185",
      "count": 3
    },
    {
      "unit": "Unit",
      "id": "SOR_040",
      "count": 3
    }
  ]
}
```

</details>

The format kind of sucks, but it would be trivial to interop with.

### [tcgplayer.com](https://www.tcgplayer.com/)

Maintains a set of [price guides](https://www.tcgplayer.com/categories/trading-and-collectible-card-games/star-wars-unlimited), and provides a set of [APIs](https://help.tcgplayer.com/hc/en-us/articles/201577976-How-can-I-get-access-to-your-card-pricing-data) in order to get
real-time pricing data (and even affiliate links).

### [youtube.com](https://youtube.com)

Some creator's post decklists on YouTube, which could be scraped.

For example [Thorrk's Hot Takes](https://www.youtube.com/feeds/videos.xml?channel_id=UChKP3DoE5J0G4mFEmenv7oA), or [KTOD](https://www.youtube.com/feeds/videos.xml?channel_id=UCpLg-Fi_v1A-NwhIWsrvY0Q).
