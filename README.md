# Sumofsquares

Check whether sum of squares of sequence of numbers is a perfect square using actor
model

### Group Info
Pulkit Tripathi (UFID: 9751-9461)
Akash Shingte (UFID: 4874-1966)


## Instructions

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
1000

Determined using manual testing by checking the execution time of the problem

### Number of workers
Number of logical cores available determined using `System.schedulers_online`


### Largest problem solved
```elixir
mix run --no-halt proj1.exs  100000000 24
```

```bash
/usr/bin/time -l mix run --no-halt 100000000 24
```
```
real 2m29.682s
user 19m29.562s
sys 0m3.081s
```
CPU time: real time = 7.81

### Results

#### Dual core
```elixir
mix run --no-halt proj1.exs   10000000 24
```
```
1
9
20
25
44
76
121
197
304
353
540
856
1301
2053
3112
3597
5448
8576
12981
20425
30908
35709
54032
84996
128601
202289
306060
468037
```

```
/usr/bin/time -l mix run --no-halt 1000000 24
```

```
1
9
20
25
44
76
121
197
304
353
540
856
1301
2053
3112
3597
5448
8576
12981
20425
30908
35709
54032
84996
128601
202289
306060
468037
        4.63 real        10.99 user         0.32 sys
  43712512  maximum resident set size
         0  average shared memory size
         0  average unshared data size
         0  average unshared stack size
     16818  page reclaims
         0  page faults
         0  swaps
         0  block input operations
         0  block output operations
         0  messages sent
         0  messages received
         8  signals received
      2041  voluntary context switches
     19912  involuntary context switches
```
CPU time : real time = (10.99 + 0.32)/4.63 = 2.44


#### Quad core

```
1
9
20
25
44
76
121
197
304
353
540
856
1301
2053
3112
3597
5448
8576
12981
20425
30908
35709
54032
84996
128601
202289
306060
468037
real    0m2.343s
user    0m7.140s
sys     0m0.160s
```

CPU time:real time = 3.06
### Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sumofsquares](https://hexdocs.pm/sumofsquares).

