require_relative 'spec_helper'

describe "A command should be serializeable" do

  class SerializeableCommand < Mutations::Command
    input do
      required do
        string :first_name
      end

      optional do
        integer :social_security_number
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
  end

  class EmptyCommand < Mutations::Command
  end

  it "Should print the code required to reconstruct itself" do
    serializedCommand = SerializeableCommand.new().to_s
    expected = %(
        input do
          
        
        required do
          string :first_name, {:strip=>true, :strict=>false, :nils=>false, :empty=>false, :min_length=>nil, :max_length=>nil, :matches=>nil, :in=>nil, :discard_empty=>false}

        end

        optional do
          integer :social_security_number, {:nils=>false, :min=>nil, :max=>nil, :in=>nil}

        end
        
      
        end

        output do
          
        
        required do
          
        end

        optional do
          integer :age, {:nils=>false, :min=>nil, :max=>nil, :in=>nil}

        hash :numbers do 
        required do
          integer :credit_card, {:nils=>false, :min=>nil, :max=>nil, :in=>nil}
integer :phone, {:nils=>false, :min=>nil, :max=>nil, :in=>nil}

        end

        optional do
          
        end
        end
      
array :friend_names, {:nils=>false, :class=>String, :arrayize=>false, :in=>nil}

        end
        
      
        end
      )
    assert_equal expected, serializedCommand
  end

  it "Should be able to repeat the sequence with the same results" do
    serialized_command = SerializeableCommand.new().to_s
    EmptyCommand.construct(serialized_command)
    serialized_empty_Command = EmptyCommand.new().to_s
    
    assert_equal serialized_command, serialized_empty_Command
  end

  it "Should throw errors like a normal command would" do
    serialized_command = SerializeableCommand.new().to_s

    EmptyCommand.construct(serialized_command)
    assert_raises Mutations::ValidationException do
      EmptyCommand.run!(:social_security_number => 1234)
    end

    EmptyCommand.run!(:first_name => "John", :social_security_number => 1234)
  end

  it "Should generate a hash" do
    input_hash_representation = SerializeableCommand.input_filters.to_hash
    output_hash_representation = SerializeableCommand.output_filters.to_hash

    assert_equal true, input_hash_representation[:first_name][:required]
    assert_equal false, input_hash_representation[:social_security_number][:required]
  end

end
