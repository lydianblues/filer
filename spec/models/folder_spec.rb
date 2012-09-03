require 'spec_helper'
describe Folder do
  describe "duplicate" do
    it "should create a node with defaults" do
      node = Folder.create!(name: "Thomas")
      node.parent_id.should be_nil
      node.filespace_id.should be_nil
      node.name.should == "Thomas"
      node.leaf.should be_true
      node.ntype.should == "regular"
    end
        
    it "should copy a node with no children" do
      fs = Filespace.generate!(name: "My Filespace")
      current = fs.current_folder
      node = Folder.new(name: "Thomas")
      node.filespace_id = fs.id,
      node.parent_id =  current.id
      node.save!

      current.children.size.should == 1
      copy = node.duplicate(fs.id, current.id)
      current.children.size.should == 2
      
      node.ntype.should == copy.ntype
      node.leaf.should be_true
      copy.leaf.should be_true
      node.children.size.should == 0
      copy.children.size.should == 0
      copy.name.should == "Thomas"
    end
        
    it "should copy a node with two children" do
      fs = Filespace.generate!(name: "My Filespace")
      current = fs.current_folder
      node_1 = Folder.new(name: "Thomas")
      node_1.filespace_id = fs.id,
      node_1.parent_id =  current.id
      node_1.save!
      
      node_2 = Folder.new(name: "Thomas")
      node_2.filespace_id = fs.id,
      node_2.parent_id =  current.id
      node_2.save!
      
      node_1_1 = Folder.new(name: "Josiah")
      node_1_1.filespace_id = fs.id,
      node_1_1.parent_id =  node_1.id
      node_1_1.save!
      
      node_1_2 = Folder.new(name: "Royce")
      node_1_2.filespace_id = fs.id,
      node_1_2.parent_id =  node_1.id
      node_1_2.save!
      
      node_2.children.size.should == 0
      node_1.children.size.should == 2
      node_1.duplicate(fs.id, node_2.id)
      node_2.children.size.should == 1
      
    end
  end
end