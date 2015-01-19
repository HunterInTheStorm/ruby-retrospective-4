module UI

  class Element

    attr_writer :style

    def initialize(parent)
      @parent = parent
      @style = -> text { text }
    end

    def stylize(text)
      text = @parent.stylize(text) if @parent
      @style.call text
    end

  end

  class Label < Element

    def initialize(parent, text)
      super(parent)
      @text = text
    end

    def width
      @text.size
    end

    def height
      1
    end

    def row_to_string(row)
      stylize @text
    end

  end

  class BorderDecorator

    def initialize(element, border)
      @element = element
      @border = border
    end

    def stylize(text)
      @element.stylize text
    end

    def width
      @element.width + 2 * @border.length
    end

    def height
      @element.height
    end

    def row_to_string(row)
      element_string = @element.row_to_string(row)
      "#{@border}#{element_string.ljust(@element.width)}#{@border}"
    end

  end

  class Container < Element

    attr_reader :items

    def initialize(parent = nil, &block)
      super(parent)
      @items = []
      instance_eval(&block)
    end

    def label(text:, border: nil, style: nil)
      add decorate(Label.new(self, text), border, style)
    end

    def horizontal(border: nil, style: nil, &block)
      add decorate(HorizontalGroup.new(self, &block), border, style)
    end

    def vertical(border: nil, style: nil, &block)
      add decorate(VerticalGroup.new(self, &block), border, style)
    end

    private

    def add(element)
      @items << element
    end

    def decorate(element, border, style)
      element.style = :downcase.to_proc if style == :downcase
      element.style = :upcase.to_proc   if style == :upcase
      element = BorderDecorator.new(element, border) if border
      element
    end

  end

  class VerticalGroup < Container

    def width
      @items.map(&:width).max
    end

    def height
      @items.map(&:height).reduce(:+)
    end

    def row_to_string(row)
      elements_reaches = @items.map.with_index do |element, index|
        [element, @items.first(index + 1).map(&:height).reduce(:+)]
      end.select { |_, element_reach| row < element_reach }
      element, element_reach = elements_reaches.first
      element.row_to_string(row - element_reach + element.height)
    end

  end

  class HorizontalGroup < Container

    def row_to_string(row)
      @items.map { |element| element_to_s element, row }.join
    end

    def width
      @items.map(&:width).reduce(:+)
    end

    def height
      @items.map(&:height).max
    end

    private

    def element_to_s(element, row)
      if element.height > row
        element.row_to_string row
      else
        " " * element.width
      end
    end

  end

  class TextScreen < HorizontalGroup

    def self.draw(&block)
      new(&block)
    end

    def to_s
      (0...height).map { |row| "#{row_to_string(row)}\n" }.join
    end

  end

end
