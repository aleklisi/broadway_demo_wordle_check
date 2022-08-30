defmodule Wordle do
  def color_word(actuall, guess) do
    actuall_lst = :binary.bin_to_list(actuall)
    guess_lst = :binary.bin_to_list(guess)
    color(guess_lst, actuall_lst)
  end

  defp color(guess_lst, actuall_lst) do
    green = green(guess_lst, actuall_lst)

    actual_possibly_yellow =
      [green, actuall_lst]
      |> List.zip()
      |> Enum.filter(fn
        {:green, _} -> false
        _ -> true
      end)
      |> Enum.map(fn {_, letter} -> letter end)
      |> List.foldl(%{}, fn letter, letters_count_map ->
        old = Map.get(letters_count_map, letter, 0)
        Map.put(letters_count_map, letter, old + 1)
      end)

    yellow_or_gray(guess_lst, green, actual_possibly_yellow)
    |> Enum.map(fn {_, color} -> color end)
  end

  defp green(guess_lst, actuall_lst) do
    [guess_lst, actuall_lst]
    |> List.zip()
    |> Enum.map(fn
      {x, x} -> :green
      _ -> :not_green
    end)
  end

  defp yellow_or_gray([], _green, _actual_possibly_yellow), do: []

  defp yellow_or_gray([guess_hd | guess_tail], [:green | green_tail], actual_possibly_yellow) do
    [{guess_hd, :green} | yellow_or_gray(guess_tail, green_tail, actual_possibly_yellow)]
  end

  defp yellow_or_gray([guess_hd | guess_tail], [:not_green | green_tail], actual_possibly_yellow) do
    if Map.has_key?(actual_possibly_yellow, guess_hd) do
      new_actual_possibly_yellow =
        case Map.get(actual_possibly_yellow, guess_hd) do
          1 -> Map.delete(actual_possibly_yellow, guess_hd)
          n -> Map.put(actual_possibly_yellow, guess_hd, n - 1)
        end

      [
        {guess_hd, :yellow}
        | yellow_or_gray(
            guess_tail,
            green_tail,
            new_actual_possibly_yellow
          )
      ]
    else
      [
        {guess_hd, :gray}
        | yellow_or_gray(guess_tail, green_tail, actual_possibly_yellow)
      ]
    end
  end
end
