# Sumofsquares

Check whether sum of squares of sequence of numbers is a perfect square using actor
model

###Group Info
Pulkit Tripathi (UFID: 9751-9461)
Akash Shingte (UFID: 4874-1966)


##Instructions

### Dependencies

Install dependencies using
```elixir
mix deps.get
```
### Compilation 

Compile the project using
```elixir
mix compile
```
### Execution

Execute the project using
```elixir
mix run --no-halt proj1.exs   <limit> <sequence_length>
```
Usage: mix run --no-halt proj1.exs  <limit:int()> <sequence_length:int()>"

### Timing 

```bash
/usr/bin/time -l mix run --no-halt <limit> <sequence_length>
```

### Size of work unit
10000

### Largest problem solved
```elixir
mix run --no-halt proj1.exs  100000000 24
```

```bash
/usr/bin/time -l mix run --no-halt 100000000 24
```
### Results

```elixir
mix run --no-halt proj1.exs   10000000 24
```

####TODO: add output

```bash
/usr/bin/time -l mix run --no-halt <limit> <sequence_length>
```

####TODO: add output




Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sumofsquares](https://hexdocs.pm/sumofsquares).

