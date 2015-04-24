require "charter/version"
require "charter/chart"

module Charter
  def self.draw(*args)
    Chart.draw(*args)
  end
end
