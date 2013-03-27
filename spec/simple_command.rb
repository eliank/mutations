class SimpleCommand < Mutations::Command
  input do
    required do
      string :name, max_length: 10
      string :email
    end

    optional do
      integer :amount
    end
  end

  def execute
    inputs
  end
end