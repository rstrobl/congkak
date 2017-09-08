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

  defp play_house(board, position) do
    board = %{board | scoops: board.scoops ++ [position] }
    {board, tokens} = scoop(board, position)
    sow(board, position + 1, tokens, false)
  end

  defp tokens(board, position) do
    Enum.fetch!(board.houses, position)
  end

  defp scoop(board, position) do
    {
      %{ board | houses: List.replace_at(board.houses, position, 0) },
      tokens(board, position)
    }
  end

  defp house_empty?(board, position) do
    tokens(board, position) == 1
  end

  defp my_storehouse?(position) do
    position == 7
  end

  defp my_house?(position) do
    position < 7
  end

  defp eat(board, position) do
    opposite_position = 15 - position - 1
    tokens_to_eat = tokens(board, opposite_position)

    houses = List.replace_at(board.houses, position, 0)

    if tokens_to_eat != nil do
      houses = List.replace_at(houses, opposite_position, 0)
      houses = List.update_at(houses, 7, &(&1 + tokens_to_eat + 1))
    end

    %{ board | houses: houses }
  end

  defp sow(board, position, tokens, _) when position == 15 do
    # skip opponents storehouse and start from the top
    # since one full round has been made, we can eat the opponent's tokens
    # from now
    sow(board, 0, tokens, true)
  end

  defp sow(board, position, tokens, can_eat) do
    if tokens(board, position) == nil do
      # skip blocked houses
      sow(board, position + 1, tokens, can_eat)
    else
      board = %{ board | houses: List.update_at(board.houses, position, &(&1 + 1)) }

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
            {board, tokens} = scoop(board, position)
            sow(board, position + 1, tokens, can_eat)
          end
        end
      else
        sow(board, position + 1, tokens - 1, can_eat)
      end
    end
  end

  def my_score(board) do
    Enum.fetch!(board.houses, 7)
  end

  def make_best_move(board) do
    make_best_move(board, board)
  end

  defp make_best_move(board, best) do
    make_best_move(board, best, 0)
  end

  defp make_best_move(board, best, position) do
    cond do
      position == 7 ->
        best
      Enum.fetch!(board.houses, position) == 0 ->
        make_best_move(board, best, position + 1)
      true ->
        {state, new_board} = play_house(board, position)

        if state == :storehouse do
          make_best_move(new_board, best, 0)
        else # round finished
          if Enum.fetch!(new_board.houses, 7) > Enum.fetch!(best.houses, 7) do
            best = new_board
          end
          make_best_move(board, best, position + 1)
        end
    end
  end
end

defmodule Congkak do
  def main do
    new_game = %Game.State{}
    final_state = Game.make_best_move(new_game)

    IO.inspect final_state
    IO.inspect Game.my_score(final_state)
  end
end

Congkak.main
