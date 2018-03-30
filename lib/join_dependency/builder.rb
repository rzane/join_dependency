require "active_record"

module JoinDependency
  class Builder # :nodoc:
    attr_reader :relation

    def initialize(relation)
      @relation = relation
    end

    def to_join_dependency
      buckets = relation.joins_values
      buckets += relation.left_outer_joins_values if at_least?(5)

      buckets = buckets.group_by do |join|
        case join
        when String
          :string_join
        when Hash, Symbol, Array
          :association_join
        when Polyamorous::JoinDependency, Polyamorous::JoinAssociation
          :stashed_join
        when Arel::Nodes::Join
          :join_node
        else
          raise 'unknown class: %s' % join.class.name
        end
      end

      buckets.default = []
      association_joins         = buckets[:association_join]
      stashed_association_joins = buckets[:stashed_join]
      join_nodes                = buckets[:join_node].uniq
      string_joins              = buckets[:string_join].map(&:strip).uniq

      join_list =
        if at_least?(5)
          join_nodes + relation.send(:convert_join_strings_to_ast, relation.table, string_joins)
        else
          relation.send(:custom_join_ast, relation.table.from(relation.table), string_joins)
        end

      if at_least?(5, 2)
        alias_tracker = ::ActiveRecord::Associations::AliasTracker.create(klass.connection, relation.table.name, join_list)
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

      if at_least?(4, 1)
        join_dependency
      else
        join_dependency.graft(*stashed_association_joins)
      end
    end

    private

    def at_least?(major, minor = 0)
      ActiveRecord::VERSION::MAJOR >= major && ActiveRecord::VERSION::MINOR >= minor
    end
  end
end
