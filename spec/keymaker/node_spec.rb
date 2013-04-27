require 'spec_helper'
require 'pp'
class Terminator
  include Keymaker::Node
  property :name
  index :on => :name
  index_name :deadly_robots, :on => :name
end

describe Keymaker::Node do

  let(:terminator) { Terminator.create(name: 'T1000') }

  subject { terminator }

  it_behaves_like "ActiveModel"

  describe ".create" do
    subject { terminator }
    its(:node_id) { should be_present }
    its(:name) { should == 'T1000' }
    it { should_not be_new_node }
    it { should be_a(Terminator) }
  end

  context "callbacks" do
    context ":after_create" do
      it "adds the node type to the 'nodes' index'" do
        Terminator.neo_service.should_receive(:add_node_to_index).with('nodes', 'node_type', 'Terminator', kind_of(Integer))
        Terminator.neo_service.should_receive(:add_node_to_index).with('terminators', 'name', 'T1000', kind_of(Integer))
        Terminator.neo_service.should_receive(:add_node_to_index).with('deadly_robots', 'name', 'T1000', kind_of(Integer))
        Terminator.create(name: 'T1000')
      end
    end
  end

  describe ".find_all_by_cypher(query, params)" do

    subject { Terminator.find_all_by_cypher(query) }
    let(:query) { "START all=node(*) RETURN all" }

    context "with existing nodes" do
      before { terminator }
      it { should be_a(Array) }
      its(:first) { should_not be_new_node }
      its(:first) { should be_a(Terminator) }
    end

    context "without existing nodes" do
      it { should be_a(Array) }
      it { should be_blank }
    end

  end

  describe ".find(node_id)" do

    subject { Terminator.find(node_id) }

    context "when terminator is present" do
      let(:node_id) { terminator.node_id }

      its(:node_id) { should be_present }
      its(:name) { should == 'T1000' }
      it { should be_present }
      it { should_not be_new_node }
      it { should be_a(Terminator) }
    end

    context "when terminator is not present" do
      let(:node_id) { 9001 }
      it {should be_nil}
    end

  end


  describe ".find!(node_id)" do

    subject { Terminator.find!(node_id) }

    context "when terminator is present" do
      let(:node_id) { terminator.node_id }

      its(:node_id) { should be_present }
      its(:name) { should == 'T1000' }
      it { should be_present }
      it { should_not be_new_node }
      it { should be_a(Terminator) }
    end

    context "when terminator is not present" do
      let(:node_id) { 9001 }
      it "raises an Keymaker::ResourceNotFound error" do
        expect { subject }.to raise_error(Keymaker::ResourceNotFound)
      end
    end

  end
  
  describe ".where(attributes)" do
    subject { Terminator.where(attributes) }
    
    context "when index and value exists" do
      let(:attributes) { {:name => 'T1000'} }
      
      its(:node_id) { should be_present }
      its(:name) { should == 'T1000' }
      it { should be_present }
      it { should_not be_new_node }
      it { should be_a(Terminator) }
    end
    
    context "when index does not exist" do
      
    end
    
    context "when index value is not in index" do
      let(:attributes) { {:name => 'T8000'} }
      
      it {should be_nil}
    end
    
    context "when hash is empty" do
      let(:attributes) { {:name => 'T8000'} }
      
      it {should be_nil}
    end
  end
  describe "#persisted?" do
    let(:new_node) { Terminator.new(name: "T1000") }
    subject { node.persisted? }

    context "when persisted" do
      let(:node) { new_node.save }
      it { subject.should be_true }
    end

    context "when not persisted" do
      let(:node) { new_node }
      it { subject.should be_false }
    end

  end

  describe "#to_key" do

    context "when persisted" do
      subject { terminator.to_key }
      it { subject.first.should be_a(Integer)  }
      it { subject.should include(terminator.node_id)  }
    end

    context "when not persisted" do
      subject { Terminator.new(name: "T1000").to_key }
      it { subject.should be_blank  }
    end

  end

  describe "#to_param" do

    context "when persisted" do
      subject { terminator.to_param }
      it { subject.should == terminator.node_id.to_s }
    end

    context "when not persisted" do
      subject { Terminator.new(name: "T1000").to_param }
      it { subject.should be_nil }
    end

  end

end
