require 'rails_helper'

RSpec.describe Adiantamento, :type => :model do
  let(:adiantamento){FactoryGirl.build(:adiantamento)}
  let!(:presenca_direito_reposicao_com_justificativa){FactoryGirl.create(:presenca, :direito_a_reposicao, :com_justificativa_adiantado)}
  let(:presenca_realocacao_adiantamento){FactoryGirl.create(:presenca, :realocacao)}

  it "Cria um adiantamento" do
    expect(adiantamento).to be_valid
  end

  describe "Vinculo do adiantamento com a falta com direito a reposição" do
    it "Cria um adiantamento" do
      expect(presenca_direito_reposicao_com_justificativa.conciliamento_de.conciliamento_condition).to be_a(Adiantamento)
    end

    it "Vincula um Adiantamento com conciliamento" do
      expect(presenca_realocacao_adiantamento.conciliamento_para.conciliamento_condition).to be_a(Adiantamento)
    end
  end
end
