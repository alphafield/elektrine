defmodule ElektrineWeb.ProductHTML do
  use ElektrineWeb, :html

  embed_templates "product_html/*"

  @doc """
  Renders a product form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :stores, :list, required: true

  def product_form(assigns)
end
