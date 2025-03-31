defmodule OrderApp.OrderCalc do
  @moduledoc """
  Oblicza brakujące wartości dla encji zamówienia i pozycji zamówienia.
  """

  alias Decimal, as: D
  alias OrderApp.OrderItem
  alias OrderApp.Order

  @type tax_percent :: 0..100

  @doc "Oblicza łączną cenę netto (net_total) i brutto (total) dla pozycji zamówienia."
  @spec update_order_item(OrderItem.t(), tax_percent()) :: OrderItem.t()
  def update_order_item(%OrderItem{net_price: net_price, quantity: quantity} = item, tax_percent)
      when is_integer(tax_percent) and tax_percent in 0..100 do
    validate_item_values!(net_price, quantity)

    net_total = D.mult(net_price, D.new(quantity))
    tax_amount = D.mult(net_total, D.div(D.new(tax_percent), D.new(100)))
    total = D.add(net_total, tax_amount)
    %OrderItem{item | net_total: net_total, total: total}
  end

  def update_order_item(_, tax_percent),
    do:
      raise(
        ArgumentError,
        "Procent podatku musi być w przedziale od 0 do 100, otrzymano: #{tax_percent}"
      )

  @doc "Oblicza łączną cenę netto (net_total), podatek (tax) oraz cenę brutto (total) dla zamówienia."
  @spec update_order(Order.t(), tax_percent()) :: Order.t()
  def update_order(%Order{order_items: []}, _),
    do: raise(ArgumentError, "Zamówienie musi zawierać co najmniej jedną pozycję")

  def update_order(%Order{} = order, tax_percent) do
    updated_items = Enum.map(order.order_items, &update_order_item(&1, tax_percent))

    net_total =
      Enum.reduce(updated_items, D.new(0), fn item, acc ->
        D.add(acc, item.net_total)
      end)

    tax_total =
      Enum.reduce(updated_items, D.new(0), fn item, acc ->
        tax_amount = D.sub(item.total, item.net_total)
        D.add(acc, tax_amount)
      end)

    total = D.add(net_total, tax_total)
    %Order{order | order_items: updated_items, net_total: net_total, tax: tax_total, total: total}
  end

  defp validate_item_values!(net_price, quantity) do
    cond do
      D.negative?(net_price) ->
        raise ArgumentError, "Cena netto nie może być ujemna, otrzymano: #{net_price}"

      quantity < 0 ->
        raise ArgumentError, "Ilość nie może być ujemna, otrzymano: #{quantity}"

      true ->
        :ok
    end
  end
end
