# OrderApp

## Opis Aplikacji

Aplikacja służy do obliczania wartości zamówienia oraz jego pozycji. Na podstawie podanej ceny netto jednostkowej, ilości sztuk oraz stawki podatkowej, aplikacja uzupełnia brakujące dane – wylicza wartość netto, podatek oraz wartość brutto zarówno dla pojedynczych pozycji, jak i dla całego zamówienia. Dzięki wykorzystaniu precyzyjnych operacji arytmetycznych na liczbach dziesiętnych (biblioteka Decimal), aplikacja eliminuje problemy związane z zaokrągleniami.

## Technologie

- **Elixir:** 1.17.1-otp-27
- **Erlang:** 27.0
- **Decimal:** Biblioteka do precyzyjnych operacji na liczbach dziesiętnych

## Struktury Danych

W aplikacji korzystamy z dwóch głównych struktur:

- **OrderItem:** Reprezentuje pojedynczą pozycję zamówienia, zawiera następujące pola:
  - `net_price` – cena jednostkowa netto (Decimal)
  - `quantity` – ilość sztuk (integer)
  - `net_total` – wartość netto pozycji (Decimal)
  - `total` – wartość brutto pozycji (Decimal)

- **Order:** Reprezentuje zamówienie, zawiera:
  - `order_items` – lista pozycji zamówienia (list of OrderItem)
  - `net_total` – wartość netto zamówienia (Decimal)
  - `tax` – całkowita kwota podatku (Decimal)
  - `total` – wartość brutto zamówienia (Decimal)

## Odpowiedź na pytanie: 
#### Jakiego typu danych użyjesz do przechowywania poszczególnych wartości w bazie danych?

Do przechowywania wartości pieniężnych (takich jak `net_total`, `tax`, `total`, `net_price`) w bazie danych należy użyć typu danych **DECIMAL**. Typy te zapewniają precyzyjne operacje arytmetyczne, eliminując problemy zaokrągleń, które mogą wystąpić przy użyciu typów zmiennoprzecinkowych. Natomiast dla pola `quantity` wystarczający będzie typ **INTEGER**.

## Uruchomienie Testów

1. Zainstaluj potrzebną bibliotekę Decimal.
```bash
  mix deps.get
```

2. Uruchom testy
```bash
  mix test
```
