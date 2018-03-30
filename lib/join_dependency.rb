require "join_dependency/version"
require "join_dependency/builder"

module JoinDependency
  def self.from(relation)
    builder = Builder.new(relation)
    builder.to_join_dependency
  end
end
