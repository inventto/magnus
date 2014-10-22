require 'rails_helper'

RSpec.describe Reposicao, type: :model do
  let(:reposicao){FactoryGirl.build(:reposicao)}
  it "Criar uma reposição" do
    expect(reposicao).to be_valid
  end
  it "Valida reposição" do
    presenca_direito_reposicao = FactoryGirl.create :presenca, :direito_a_reposicao
    realocacao = FactoryGirl.create :presenca, :realocacao
  end
end
