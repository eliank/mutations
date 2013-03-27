require_relative 'spec_helper'

describe "A command should be serializeable" do
  
  class SerializeableCommand < Mutations::Command
    
    input do
      required do
        string :first_name        
      end
    end

    output do
      optional do
        integer :age
        hash :numbers do
          integer :credit_card
          integer :phone
        end

        array :friend_names, class: String
      end
    end

    def execute
      {:age => 50}
    end

  end

  it "Should print the code required to reconstruct itself" do
    puts SerializeableCommand.new().to_s
  end

end