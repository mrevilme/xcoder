require_relative 'spec_helper'

describe Xcode::Scheme do 
  let :project do
    Xcode.project 'TestProject'
  end
  
  let :workspace do
    Xcode.workspace 'TestWorkspace'
  end
  
  context "Project schemes" do
    it "should parse project schemes" do 
      scheme = project.scheme('TestProject')
      scheme.name.should=="TestProject"
      scheme.build_targets.first.name.should == 'TestProject'
      scheme.build_targets.first.project.name.should == 'TestProject'
    end
    
    it "should return an array of schemes" do
      project.schemes.size.should == 1
    end
  
    it "should complain that no such scheme exists" do
      lambda do 
        project.scheme('BadScheme')
      end.should raise_error
    end
  end
  
  context "Workspace schemes" do
    it "should complain that no such scheme exists" do
      lambda do 
        workspace.scheme('BadScheme')
      end.should raise_error
    end
  
    it "should return an array of schemes" do
      workspace.schemes.size.should == 2
    end
  
    it "should parse workspace schemes" do 
      scheme = workspace.scheme('WorkspaceScheme')
      scheme.name.should=="WorkspaceScheme"
      scheme.build_targets.first.name.should == 'TestProject'
      scheme.build_targets.first.project.name.should == 'TestProject'
    end
  end
  

end