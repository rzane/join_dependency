class CustomJoin
end

RSpec.describe JoinDependency do
  let :custom do
    CustomJoin.new
  end

  it "has a version number" do
    expect(JoinDependency::VERSION).not_to be nil
  end

  it "can convert a relation to a join dependency" do
    relation = Post.joins(:author)
    jd = JoinDependency.from(relation)
    expect(jd).to be_an(ActiveRecord::Associations::JoinDependency)
  end

  it "includes association join children" do
    relation = Post.joins(:author)
    jd = JoinDependency.from(relation)
    children = jd.send(:join_root).children
    reflection = children.first.reflection

    expect(reflection).to eq(Post.reflect_on_association(:author))
  end

  it "raises on unknown join" do
    relation = Post.joins(custom)

    expect {
      JoinDependency.from(relation)
    }.to raise_error(RuntimeError, 'unknown class: CustomJoin')
  end

  it "allows injecting a custom join" do
    relation = Post.joins(custom)

    jd = JoinDependency.from(relation) do |join|
      expect(join).to eq(custom)
      :stashed_join
    end

    expect(jd).to be_an(ActiveRecord::Associations::JoinDependency)
  end

  it "raises if the block returns nil" do
    relation = Post.joins(custom)

    expect {
      JoinDependency.from(relation) do |join|
        expect(join).to eq(custom)
        nil
      end
    }.to raise_error(RuntimeError, 'unknown class: CustomJoin')
  end
end
