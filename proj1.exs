usage_string = "Invalid arguments to the command\nUsage: mix run proj1.exs --no-halt <limit:int()> <sequence_length:int()>"
try do
  if length(System.argv) != 2 do
    raise ArgumentError
  end
  [limit, sequence_length] = Enum.map(System.argv, fn x -> String.to_integer(x) end)
  Sumofsquares.Boss.calculate(limit, sequence_length)
rescue
  _e in ArgumentError -> IO.puts usage_string
end

