require 'rails_helper'

RSpec.describe Adiantamento, :type => :model do
  let!(:presenca_direito_reposicao_com_justificativa){FactoryGirl.create(:presenca, :direito_a_reposicao_de_adiantamento, :com_justificativa_adiantado)}
  let(:presenca_realocacao_adiantamento){FactoryGirl.create(:presenca, :realocacao_de_adiantamento)}

  describe "Vinculo do adiantamento com a falta com direito a reposição" do
    it "Cria um adiantamento" do
      expect(presenca_direito_reposicao_com_justificativa.conciliamento_de.conciliamento_condition).to be_a(Adiantamento)
    end

    it "Cria apenas um adiantamento" do
      expect(Adiantamento.count).to eq(1)
    end

    it "Cria apenas um conciliamento" do
      expect(Conciliamento.count).to eq(1)
    end

    it "Verifica se a reposição cria um novo conciliamento" do
      expect(presenca_realocacao_adiantamento)
    end

    it "Não deve criar uma repoisção" do
      expect(Reposicao.count).to eq(0)
    end
  end
end
