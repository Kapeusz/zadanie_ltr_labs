defmodule OrderApp.OrderItem do
  @moduledoc """
  Struktura reprezentująca pozycję zamówienia.
  """
  @type t :: %__MODULE__{
          net_price: Decimal.t() | nil,
          quantity: integer() | nil,
          net_total: Decimal.t() | nil,
          total: Decimal.t() | nil
        }

  defstruct net_price: nil, quantity: nil, net_total: nil, total: nil
end
