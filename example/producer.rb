require 'lapine'

class Producer
  include Lapine::Publisher

  exchange 'lapine.topic'

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def to_hash
    {
      data: id
    }
  end
end

