require_relative "field"

module SRM
# A register array is a register with num_entries.
class RegisterArray
  attr_reader :type, :name, :fields, :width, :num_entries, :offsets

  def initialize(name:, fields: [], num_entries: 1)
    @type = "RegisterArray"
    @name = name
    @fields = fields
    @num_entries  = num_entries
    yield self if block_given?

    sum_nbits = @fields.inject(0) { |sum_nbits, field| sum_nbits + field.nbits} 
    @width = (sum_nbits % 8 == 0) ? sum_nbits/8 : (sum_nbits + 8)/8;
    @default_size = @width * num_entries
    @offsets = {}
  end

  def dup(new_name)
    RegisterArray.new(name: new_name, fields: self.fields, num_entries: self.num_entries)
  end

  def hash
    name.hash ^ fields.hash ^ num_entries 
  end

  def ==(other)
    return true if other.equal?(self)
    name == other.name && fields == other.fields && num_entries == other.num_entries
  end

  def eql?(other)
    self.==(other)
  end

  def <<(field)
    @fields << field
  end

  def offset(args)
    args.each do |addr_map, value|
      if value.kind_of?(Array)
        raise(Argumenterror, "Must Specify offset and size") if value.size > 2
        start = value[0]
        #if single entry array then use the default size else use the user value.
        size = value.size == 1 ? @default_size : value[1];  
      else
        start = value
        size = @default_size
      end
      @offsets[addr_map] = [start, size]
    end
    self
  end

  def to_json(options={})
    {
      "type" => type,
      "name" => name,
      "num_entries" => num_entries,
      "width" => width,
      "fields" => @fields,
      "offsets" => @offsets
    }.to_json(options)
  end

end
end
