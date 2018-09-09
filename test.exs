{:ok, boss} = Sumofsquares.Boss.start_link([])
:ok = Sumofsquares.Boss.calculate(boss, 6000000, 24)
