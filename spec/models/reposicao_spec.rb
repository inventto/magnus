require 'rails_helper'

RSpec.describe Reposicao, type: :model do
  let(:reposicao){FactoryGirl.build(:reposicao)}
  let!(:presenca_direito_reposicao){FactoryGirl.create(:presenca, :direito_a_reposicao)}
  let(:presenca_realocacao){FactoryGirl.create(:presenca, :realocacao)}

  it "Criar uma reposição" do
    expect(reposicao).to be_valid
  end

  describe "vinculo da reposição com as presenças" do
    it "Cria uma reposição apartir de uma falta com direito a reposição" do
      expect(presenca_direito_reposicao.conciliamento_de.conciliamento_condition).to be_a(Reposicao)
    end

    it "Vincula uma reposição com um conciliamento" do 
      expect(presenca_realocacao.conciliamento_para.conciliamento_condition).to be_a(Reposicao)
    end

    it "Conciliamento com para id é nil?" do
      expect(presenca_realocacao.conciliamento_para).not_to be_nil
    end
  end
end
