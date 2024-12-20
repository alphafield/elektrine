defmodule ElektrineWeb.StoreHTML do
  use ElektrineWeb, :html

  embed_templates "store_html/*"

  @doc """
  Renders a store form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def store_form(assigns)
end
