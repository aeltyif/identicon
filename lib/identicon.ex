defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_even
    |> build_pixle_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
    %Identicon.Image{image| grid: grid}
  end

  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  def filter_odd_even(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  def build_pixle_map(%Identicon.Image{grid: grid} = image) do
    pixle_map = Enum.map grid, fn({_code, index}) ->
      hori = rem(index, 5) * 50
      vert = div(index, 5) * 50

      top_left = {hori, vert}
      bottom_right = {hori + 50, vert + 50}
      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixle_map: pixle_map}
  end

  def draw_image(%Identicon.Image{color: color, pixle_map: pixle_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixle_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end
end
