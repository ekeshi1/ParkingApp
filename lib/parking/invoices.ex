defmodule Parking.Invoices do

  import Ecto.Query, warn: false
  alias Parking.Repo

  alias Parking.Invoices.Invoice

  def list_invoices do
    Repo.all(Invoice)
  end

  def list_my_invoices(id) do
    query = from invoice in Invoice, select: invoice, where: invoice.user_id == ^id

    Repo.all(query)
  end

  def get_invoice!(id), do: Repo.get!(Invoice, id)

  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  def change_invoice(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
  end
end
