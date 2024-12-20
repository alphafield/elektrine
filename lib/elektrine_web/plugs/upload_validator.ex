defmodule ElektrineWeb.Plugs.UploadValidator do
  @allowed_types ~w(image/jpeg image/png image/gif)
  @max_file_size 5_242_880  # 5MB in bytes

  def validate_upload(upload) do
    with :ok <- validate_file_type(upload),
         :ok <- validate_file_size(upload) do
      :ok
    else
      {:error, message} -> {:error, message}
    end
  end

  defp validate_file_type(%{content_type: type}) do
    if type in @allowed_types do
      :ok
    else
      {:error, "Invalid file type. Allowed types: JPG, PNG, GIF"}
    end
  end

  defp validate_file_size(%{path: path}) do
    case File.stat(path) do
      {:ok, %{size: size}} when size <= @max_file_size ->
        :ok
      {:ok, _} ->
        {:error, "File too large. Maximum size is 5MB"}
      {:error, _} ->
        {:error, "Could not read file size"}
    end
  end
end
