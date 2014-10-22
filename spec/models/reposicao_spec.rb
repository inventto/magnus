require 'rails_helper'

RSpec.describe Reposicao, type: :model do
  let(:reposicao){FactoryGirl.build(:reposicao)}
  it "Criar uma reposição" do 
    expect(reposicao).to be_valid
  end
  it "Valida reposição" do

  end
end
