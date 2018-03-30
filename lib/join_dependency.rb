require "active_record"
require "join_dependency/version"

module JoinDependency
  class << self
    def from_relation(relation, &block)
      build(relation, collect_joins(relation, &block))
    end

    private

    def collect_joins(relation, &block)
      joins = []
      joins += relation.joins_values
      joins += relation.left_outer_joins_values if at_least?(5)

      buckets = joins.group_by do |join|
        case join
        when String
          :string_join
        when Hash, Symbol, Array
          :association_join
        when Arel::Nodes::Join
          :join_node
        else
          (block_given? && yield(join)) || raise("unknown class: %s" % join.class.name)
        end
      end
    end

    def build(relation, buckets)
      buckets.default = []
      association_joins         = buckets[:association_join]
      stashed_association_joins = buckets[:stashed_join]
      join_nodes                = buckets[:join_node].uniq
      string_joins              = buckets[:string_join].map(&:strip).uniq

      join_list =
        if at_least?(5, 2)
          join_nodes + relation.send(:convert_join_strings_to_ast, string_joins)
        elsif at_least?(5)
          join_nodes + relation.send(:convert_join_strings_to_ast, relation.table, string_joins)
        else
          relation.send(:custom_join_ast, relation.table.from(relation.table), string_joins)
        end

      if at_least?(5, 2)
        alias_tracker = ::ActiveRecord::Associations::AliasTracker.create(relation.klass.connection, relation.table.name, join_list)
        join_dependency = ::ActiveRecord::Associations::JoinDependency.new(relation.klass, relation.table, association_joins, alias_tracker)
        join_nodes.each do |join|
          join_dependency.send(:alias_tracker).aliases[join.left.name.downcase] = 1
        end
      else
        join_dependency = ::ActiveRecord::Associations::JoinDependency.new(relation.klass, association_joins, join_list)
        join_nodes.each do |join|
          join_dependency.send(:alias_tracker).aliases[join.left.name.downcase] = 1
        end
      end

      join_dependency
    end

    def at_least?(major, minor = 0)
      ActiveRecord::VERSION::MAJOR >= major && ActiveRecord::VERSION::MINOR >= minor
    end
  end
end
