module RBFS

  class File


    attr_accessor :data
    attr_reader :data_type


    def initialize(data=nil)
      @data = data
        if (data.is_a? String)        then @data_type = :string
        elsif (data.is_a? NilClass)   then @data_type = :nil
        elsif (data.is_a? Symbol)     then @data_type = :symbol
        elsif (data.is_a? TrueClass)  then @data_type = :boolean
        elsif (data.is_a? FalseClass) then @data_type = :boolean
        elsif (data.is_a? Numeric)    then @data_type = :number
        end
    end


    def serialize

      @data_type.to_s + ":" + @data.to_s

    end

    def self.parse(string_data)

      arr = string_data.split(':',2)
      if    (arr[0] == "boolean")      then  RBFS::File.new(arr[1] == "true")
      elsif (arr[0] == "string")       then  RBFS::File.new(arr[1])
      elsif (arr[0] == "number")       then  RBFS::File.new(arr[1].to_i)
      elsif (arr[0] == "nil")          then  RBFS::File.new
      elsif (arr[0] == "symbol")       then  RBFS::File.new(arr[1].to_sym)
      else                                   RBFS::File.new(arr[1].to_f)
      end

    end

  end


  class Directory

    attr_reader :files
    attr_reader :directories


    def initialize()
      @files = {}
      @directories = {}
    end

    def add_file(name, file)
      @files[name] = file
    end


    def add_directory(name, directory = nil)
      if directory == nil
      @directories[name] = RBFS::Directory.new
      else
      @directories[name] = directory
      end
    end

    def [](name)
      return @directories[name] if @directories.has_key?(name)
      return @files[name] if @files.has_key?(name)
    end

    def serialize

      data = @files.size.to_s + ":"
      @files.each do |key, value|
        data += key.to_s + ":" + value.serialize.size.to_s + ":" + value.serialize
      end

      data += @directories.size.to_s + ":"
      @directories.each do |key, value|
        data += key.to_s + ":" + value.serialize.size.to_s + ":" + value.serialize
      end

      data

    end

    def parse_helper(string_data)

      array = string_data.split(':', 2)
      mark, array = array[0].to_i , array[1]

      while mark != 0 do
        array = array.split(':', 3)
        file = array[2].to_s
        add_file(array[0].to_s, RBFS::File.parse(file[0,array[1].to_i]))
        array, mark = file[array[1].to_i, array[2].size - 1] , mark - 1

      end

      parse_helper_two(array)

    end

    def parse_helper_two(string_data)

      array = string_data.split(':',2)
      mark, array = array[0].to_i , array[1]

      while mark != 0 do
        array = array.split(':',3)
        file = array[2].to_s
        add_directory(array[0].to_s, RBFS::Directory.parse(file[0,array[1].to_i]))
        array = file[array[1].to_i, array[2].size - 1]
        mark -= 1
      end

    end

    def self.parse(string_data)

      folder = RBFS::Directory.new
      folder.parse_helper(string_data)
      folder

    end

  end

end
