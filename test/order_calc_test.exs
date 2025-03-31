defmodule OrderApp.OrderCalcTest do
  use ExUnit.Case
  alias Decimal, as: D
  alias OrderApp.OrderCalc
  alias OrderApp.Order
  alias OrderApp.OrderItem

  describe "update_order_item/2" do
    test "oblicza wartości dla pojedynczej pozycji zamówienia" do
      # Dla pozycji: cena netto = 100, ilość = 2, podatek = 10%
      item = %OrderItem{net_price: D.new("100.00"), quantity: 2}
      updated_item = OrderCalc.update_order_item(item, 10)
      # net_total = 100 * 2 = 200.00
      assert D.normalize(updated_item.net_total) == D.normalize(D.new("200.00"))
      # podatek = 200 * 10% = 20.00, total = 200 + 20 = 220.00
      assert D.normalize(updated_item.total) == D.normalize(D.new("220.00"))
    end

    test "obsługuje zerowy procent podatku" do
      # Dla pozycji: cena netto = 100, ilość = 2, podatek = 0%
      item = %OrderItem{net_price: D.new("100.00"), quantity: 2}
      updated_item = OrderCalc.update_order_item(item, 0)
      assert D.normalize(updated_item.net_total) == D.normalize(D.new("200.00"))
      assert D.normalize(updated_item.total) == D.normalize(D.new("200.00"))
    end

    test "obsługuje 100% podatku" do
      # Dla pozycji: cena netto = 100, ilość = 2, podatek = 100%
      item = %OrderItem{net_price: D.new("100.00"), quantity: 2}
      updated_item = OrderCalc.update_order_item(item, 100)
      assert D.normalize(updated_item.net_total) == D.normalize(D.new("200.00"))
      assert D.normalize(updated_item.total) == D.normalize(D.new("400.00"))
    end

    test "podnosi wyjątek dla ujemnej ceny netto" do
      # Dla pozycji: cena netto = -100, ilość = 2
      item = %OrderItem{net_price: D.new("-100.00"), quantity: 2}

      assert_raise ArgumentError, "Cena netto nie może być ujemna, otrzymano: -100.00", fn ->
        OrderCalc.update_order_item(item, 10)
      end
    end

    test "podnosi wyjątek dla ujemnej ilości" do
      # Dla pozycji: cena netto = 100, ilość = -2
      item = %OrderItem{net_price: D.new("100.00"), quantity: -2}

      assert_raise ArgumentError, "Ilość nie może być ujemna, otrzymano: -2", fn ->
        OrderCalc.update_order_item(item, 10)
      end
    end

    test "podnosi wyjątek dla nieprawidłowego procentu podatku" do
      # Dla pozycji: cena netto = 100, ilość = 2, podatek = 101%
      item = %OrderItem{net_price: D.new("100.00"), quantity: 2}

      assert_raise ArgumentError,
                   "Procent podatku musi być w przedziale od 0 do 100, otrzymano: 101",
                   fn ->
                     OrderCalc.update_order_item(item, 101)
                   end
    end
  end

  describe "update_order/2" do
    test "oblicza wartości dla zamówienia z wieloma pozycjami" do
      # Utwórz zamówienie z dwoma pozycjami:
      # Pozycja 1: cena netto = 100, ilość = 2  => net_total = 200, podatek = 20, total = 220
      # Pozycja 2: cena netto = 50, ilość = 3   => net_total = 150, podatek = 15, total = 165
      order = %Order{
        order_items: [
          %OrderItem{net_price: D.new("100.00"), quantity: 2},
          %OrderItem{net_price: D.new("50.00"), quantity: 3}
        ]
      }

      updated_order = OrderCalc.update_order(order, 10)

      # Dla zamówienia: net_total = 200 + 150 = 350.00, podatek = 20 + 15 = 35.00, total = 350 + 35 = 385.00
      assert updated_order.net_total == D.new("350.00")
      assert D.normalize(updated_order.tax) == D.normalize(D.new("35.00"))
      assert D.normalize(updated_order.total) == D.normalize(D.new("385.00"))
    end

    test "podnosi wyjątek dla pustego zamówienia" do
      # Utwórz zamówienie bez pozycji
      order = %Order{order_items: []}

      assert_raise ArgumentError, "Zamówienie musi zawierać co najmniej jedną pozycję", fn ->
        OrderCalc.update_order(order, 10)
      end
    end

    test "obsługuje zamówienie z jedną pozycją" do
      # Utwórz zamówienie z jedną pozycją: cena netto = 100, ilość = 2, podatek = 10%
      order = %Order{
        order_items: [
          %OrderItem{net_price: D.new("100.00"), quantity: 2}
        ]
      }

      updated_order = OrderCalc.update_order(order, 10)
      assert updated_order.net_total == D.new("200.00")
      assert D.normalize(updated_order.tax) == D.normalize(D.new("20.00"))
      assert D.normalize(updated_order.total) == D.normalize(D.new("220.00"))
    end
  end
end
