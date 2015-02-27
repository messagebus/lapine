module Lapine
  class LapineError < StandardError; end
  class UndefinedConnection < LapineError; end
  class UndefinedExchange < LapineError; end
  class NilExchange < LapineError; end
end
