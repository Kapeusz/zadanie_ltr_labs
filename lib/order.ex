defmodule OrderApp.Order do
  @moduledoc """
  Struktura reprezentująca zamówienie.
  """
  @type t :: %__MODULE__{
          order_items: [OrderApp.OrderItem.t()],
          net_total: Decimal.t() | nil,
          tax: Decimal.t() | nil,
          total: Decimal.t() | nil
        }

  defstruct order_items: [], net_total: nil, tax: nil, total: nil
end
