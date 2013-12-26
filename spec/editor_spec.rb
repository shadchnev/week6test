require 'spec_helper'
require 'editor'

describe Editor do

  let(:editor) { Editor.new }
  let(:editor_3_4) { editor.do_command('I 3 4'); editor }

  context 'new objects' do
    it 'should be initialized with a welcome message and prompt' do
      output = capture_output { editor }
      output.should include('Welcome to the graphical editor')
      output.should include('Please enter a command')
    end

    it 'should be initialized with a list of the commands' do
      output = capture_output { editor }
      Editor::COMMANDS.each_pair do |cmd, description|
        output.should include("#{cmd}: #{description}" )
      end
    end
  end # of context

  context 'parsing space-separated input' do
    it 'should yield the command and an array of paramaters' do
      capture_output do
        editor.parse('cmd p1 p2 p3').should eq(['cmd', ['p1', 'p2', 'p3']])
      end
    end

    it 'should convert parameters represented by digits only to integers' do
      capture_output do
        editor.parse('cmd p1 2 45').should eq(['cmd', ['p1', 2, 45]])
      end
    end

    it 'should give a prompt on null or any whitespace entry' do
      whitespace, msg = ['',' ',"\t"," \t\r"], 'Please enter a valid command'
      capture_output do
        whitespace.each { |ws| editor.do_command(ws).should eq(msg) }
      end
    end
  end # of context

  context 'validating input' do
    it 'should give a prompt with commands list if an invalid command used' do
      capture_output do
        editor.do_command('Z').should eq("'Z' is not valid, try 'help'")
      end
    end

    it 'should give a prompt with commands list if lower-case command used' do
      capture_output do
        editor.do_command('s').should eq("'s' is not valid, try 'help'")
      end
    end
  end # of context

  context 'command X' do
    it 'should exit the app' do
      capture_output do
        lambda { editor.do_command('X') }.should raise_error(SystemExit)
      end
    end

    it 'should display an error message if parameters provided' do
      capture_output do
        editor.do_command('X 2 3').should eq("'X' does not take parameters.")
      end
    end
  end # of context

  context 'command I' do
    it "should create a 2 by 3 grid of O's with args 2 3" do
      capture_output do
        editor.do_command('I 2 3').to_s.should eq("OO\nOO\nOO")
      end
    end

    it "should display an error message with zero or negative coords" do
      capture_output do
        editor.do_command('I 0 3').should eq('Invalid coordinates')
        editor.do_command('I 250 -2').should eq('Invalid coordinates')
      end
    end

    it "should display an error message with args 251 3" do
      capture_output do
        editor.do_command('I 251 3').should eq('Maximum size is 250 x 250')
      end
    end
  end # of context

  context 'command S' do
    it "should print a 2 by 3 grid of O's with args 2 3" do
      output = capture_output do
        e = editor
        e.do_command('I 2 3')
        e.do_command('S')
      end
      output[-9..-2].should eq("OO\nOO\nOO")
    end

    it 'should display an error message if parameters are provided' do
      capture_output do
        editor.do_command('S 2 3').should eq("'S' does not take parameters.")
      end
    end
  end # of context

  context 'command L' do
    it "should colour a single pixel with args '2 3 A'" do
      output = capture_output do
        e = editor_3_4
        e.do_command('L 2 3 A')
        e.do_command('S')
      end
      output[-16..-2].should eq("OOO\nOOO\nOAO\nOOO")
    end

    it "should display an error message when no image has been created" do
      capture_output do
        editor.do_command('L 2 3 A').should eq('Create an image first (I)')
      end
    end
  end # of context

  context 'command C' do
    it "should clear set the image to all 'O's" do
      output = capture_output do
        e = editor_3_4
        e.do_command('L 2 3 A')
        e.do_command('C')
        e.do_command('S')
      end
      output[-16..-2].should eq("OOO\nOOO\nOOO\nOOO")
    end

    it "should not cause an error if there is no image" do
      capture_output do
        lambda { editor.do_command('C') }.should_not raise_error
      end
    end

    it 'should display an error message if parameters are provided' do
      capture_output do
        editor.do_command('C 2 3').should eq("'C' does not take parameters.")
      end
    end
  end # of context


end # of describe
