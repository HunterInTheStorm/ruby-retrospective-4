def fibonacci(number)
  return number if number < 2
  fibonacci(number - 1) + fibonacci(number - 2)
end

def lucas(number)
  return 1 if number == 2
  return 2 if number == 1
  lucas(number - 1) + lucas(number - 2)
end

def series(name, number)
  case name
    when "lucas"     then lucas     number
    when "fibonacci" then fibonacci number
    when "summed"    then fibonacci(number) + lucas(number)
  end
end
