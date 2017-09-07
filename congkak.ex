#     8  9 10 11 12 13 14 (15)
# (7) 6  5  4  3  2  1  0

defmodule Game do
  defmodule State do
    defstruct(
      houses: [
        7, 7, 7, 7, 7, 7, 7, 0,
        7, 7, 7, 7, 7, 7, 7, 0
      ],
      scoops: []
    )
  end

  def scoop(board, position) do
    tokens = Enum.fetch!(board.houses, position)
    board = %State{
      houses: List.replace_at(board.houses, position, 0),
      scoops: board.scoops
    }

    {:ok, board, tokens}
  end

  defp house_empty?(board, position) do
    Enum.fetch!(board.houses, position) == 1
  end

  defp my_storehouse?(position) do
    position == 7
  end

  defp my_house?(position) do
    position < 7
  end

  defp eat(board, position) do
    opposite_position = 15 - position - 1
    tokens_to_eat = Enum.fetch!(board.houses, opposite_position)

    houses = List.replace_at(board.houses, position, 0)

    if tokens_to_eat != nil do
      houses = List.replace_at(houses, opposite_position, 0)
      houses = List.update_at(houses, 7, &(&1 + tokens_to_eat + 1))
    end

    %State{ houses: houses, scoops: board.scoops }
  end

  defp sow(board, position, tokens, _) when position == 15 do
    # skip opponents storehouse and start from the top
    sow(board, 0, tokens, true)
  end

  defp sow(board, position, tokens, can_eat) do
    if Enum.fetch!(board.houses, position) == nil do
      sow(board, position + 1, tokens, can_eat)
    else
      board = %State{ houses: List.update_at(board.houses, position, &(&1 + 1)), scoops: board.scoops }

      if tokens == 1 do
        if my_storehouse?(position) do
          {:storehouse, board}
        else
          if house_empty?(board, position) do
            if can_eat && my_house?(position) do
              {:eat, eat(board, position)}
            else
              {:end, board}
            end
          else
            {:ok, board, tokens} = scoop(board, position)
            sow(board, position + 1, tokens, can_eat)
          end
        end
      else
        sow(board, position + 1, tokens - 1, can_eat)
      end
    end
  end

  def make_best_move do
    make_best_move(%Game.State{})
  end

  def make_best_move(board) do
    make_best_move(board, board)
  end

  def make_best_move(board, best) do
    make_best_move(board, best, 0)
  end

  def make_best_move(board, best, position) do
    cond do
      position == 7 ->
        best
      Enum.fetch!(board.houses, position) == 0 ->
        make_best_move(board, best, position + 1)
      true ->
        board = %State {
          houses: board.houses,
          scoops: board.scoops ++ [position]
        }
        {:ok, board, tokens} = scoop(board, position)
        {state, board} = sow(board, position + 1, tokens, false)

        if state == :storehouse do
          make_best_move(board, best, 0)
        else # round finished
          if Enum.fetch!(board.houses, 7) > Enum.fetch!(best.houses, 7) do
            tmp_best = board
          else
            tmp_best = best
          end

          make_best_move(board, tmp_best, position + 1)
        end
    end
  end
end

defmodule Congkak do
  def main do
    state = Game.make_best_move

    IO.inspect state
    IO.inspect Enum.fetch!(state.houses, 7)
  end
end

Congkak.main
