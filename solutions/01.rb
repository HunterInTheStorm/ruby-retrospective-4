def fibonacci(number)
  if number < 2
    number
  else
    fibonacci(number - 1) + fibonacci(number - 2)
  end
end

def lucas(number)
  case number
    when 1 then 2
    when 2 then 1
    else lucas(number - 1) + lucas(number - 2)
  end
end

def series(name, number)
  case name
    when "lucas"     then series(number)
    when "fibonacci" then fibonacci(number)
    when "summed"    then fibonacci(number) + lucas(number)
  end
end
