# JoinDependency [![Build Status](https://travis-ci.org/rzane/join_dependency.svg?branch=master)](https://travis-ci.org/rzane/join_dependency)

This is a module with a singular purpose. It creates an `ActiveRecord::Associations::JoinDependency` from an `ActiveRecord::Relation`. That's it.

```ruby
require 'join_dependency'

relation = Post.joins(:author)
JoinDependency.from_relation(relation)
```

And, in case you're trying to bend Active Record to your will, you can choose how certain joins get categorized:

```ruby
JoinDependency.from_relation(relation) do |join|
  case join
  when Polyamorous::InnerJoin, Polyamorous::OuterJoin
    :stashed_association_join
  end
end
```

This library isn't meant for people. It's a library for libraries on top of other libraries that interact with libraries.
