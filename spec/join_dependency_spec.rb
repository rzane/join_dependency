RSpec.describe JoinDependency do
  it "has a version number" do
    expect(JoinDependency::VERSION).not_to be nil
  end

  it "can convert a relation to a join dependency" do
    jd = JoinDependency.from(Post.all)
    expect(jd).to be_an(ActiveRecord::Associations::JoinDependency)
  end
end
