require 'spec_helper'
describe Folder do
  
  describe "create" do
    it "should create a node with defaults" do
      node = Folder.create!(name: "Thomas")
      node.parent_id.should be_nil
      node.filespace_id.should be_nil
      node.name.should == "Thomas"
      node.leaf.should be_true
      node.ntype.should == "regular"
    end
  end
     
  describe "copy" do      
    it "should copy a node with no children" do
      fs = Filespace.generate!(name: "My Filespace")
      current = fs.current_folder
      node = Folder.new(name: "Thomas")
      node.filespace_id = fs.id,
      node.parent_id =  current.id
      node.save!
      current.children.size.should == 1
      
      copy = node.copy!(current)
      
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
      node_1.filespace = fs
      node_1.parent = current
      node_1.save!
      
      node_2 = Folder.new(name: "Edison")
      node_2.filespace = fs
      node_2.parent = current
      node_2.save!
      
      node_1_1 = Folder.new(name: "Josiah")
      node_1_1.filespace = fs
      node_1_1.parent = node_1
      node_1_1.save!
      
      node_1_2 = Folder.new(name: "Royce")
      node_1_2.filespace = fs
      node_1_2.parent = node_1
      node_1_2.save!
      
      node_2.children.size.should == 0
      node_1.children.size.should == 2
      
      node_1.copy!(node_2) # no recursion
      
      node_2.children.size.should == 1
    end
    
  end
  
  describe "copy across filespaces" do
    
    it "should copy a node between filespaces" do
      fs_1 = Filespace.generate!(name: "My Filespace 1")
      fs_2 = Filespace.generate!(name: "My Filespace 2")
      
      node_1 = Folder.new(name: "Thomas")
      node_1.filespace = fs_1
      fs_1.current_folder.children << node_1
      fs_1.current_folder.save!
      
      fs_2.current_folder.leaf.should be_true
      fs_2.current_folder.leaf.should be_true
      node_1.copy!(fs_2.current_folder)
    
      fs_2.current_folder.leaf.should be_false
      fs_2.current_folder.descendent_count.should == 1
      fs_2.current_folder.children.first.name.should == "Thomas"
    end   
  end
  
  describe "recursion" do

    it "should work with recursive copy" do
    
      #                    current
      #                    /     \
      #                   /       \
      #                Thomas   Edison
      #                /   \
      #               /     \
      #          Joshiah   Royce
      #         /  |    \
      #       /    |     \
      #  George Bernard Shaw

      fs = Filespace.generate!(name: "My Filespace")
      current = fs.current_folder
    
      node_1 = Folder.new(name: "Thomas")
      node_1.filespace = fs
      current.children << node_1
    
      node_2 = Folder.new(name: "Edison")
      node_2.filespace = fs
      current.children << node_2
    
      current.save!
    
      node_2_1 = Folder.new(name: "Josiah")
      node_2_1.filespace = fs
      node_1.children << node_2_1
    
      node_2_2 = Folder.new(name: "Royce")
      node_2_2.filespace = fs
      node_1.children << node_2_2
    
      node_1.save!
    
      node_3_1 = Folder.new(name: "George")
      node_3_1.filespace = fs
      node_2_1.children << node_3_1
    
      node_3_2 = Folder.new(name: "Bernard")
      node_3_2.filespace = fs
      node_2_1.children << node_3_2
    
      node_3_3 = Folder.new(name: "Shaw")
      node_3_3.filespace = fs
      node_2_1.children << node_3_3
    
      current.descendent_count.should == 7
    
      f = node_1.copy!(node_2, recursive: true)
      node_2.children[0].should == f
    
      node_2.descendent_count.should == 6
      node_2.children.all.size.should == 1
      node_2.children[0].name.should == "Thomas"
    
      current.descendent_count.should == 13
    
    end
  end
  
  
  describe "move"  do
    
    it "should move a node between filespaces" do
      fs_1 = Filespace.generate!(name: "My Filespace 1")
      fs_2 = Filespace.generate!(name: "My Filespace 2")

      node_1 = Folder.new(name: "Thomas")
      node_1.filespace = fs_1
      fs_1.current_folder.children << node_1
      fs_1.current_folder.save!
      
      node_1.move!(fs_2.incoming_folder)
      
      fs_1.current_folder.children.size.should == 0
      fs_2.incoming_folder.children.size.should == 1
    end
  end
  
end