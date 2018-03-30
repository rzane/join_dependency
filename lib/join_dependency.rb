require "join_dependency/version"
require "join_dependency/builder"

module JoinDependency
  def self.from(relation, &block)
    builder = Builder.new(relation)
    builder.to_join_dependency(&block)
  end
end
