class Greeter
  include Prawn::View

  def initialize(name)
    @name = name
  end

  def say_hello
    text "Hello, #{@name}!"
  end

  def say_goodbye
    font("Courier") do
      text "Goodbye, #{@name}!"
    end
  end
end

