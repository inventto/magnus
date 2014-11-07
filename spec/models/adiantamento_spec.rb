require 'rails_helper'

RSpec.describe Adiantamento, :type => :model do
  let!(:presenca_direito_reposicao_com_justificativa){FactoryGirl.create(:presenca, :direito_a_reposicao_de_adiantamento, :com_justificativa_adiantado)}
  let(:conciliamento){presenca_direito_reposicao_com_justificativa.conciliamento_de}
  let(:presenca_realocacao_adiantamento){FactoryGirl.create(:presenca, :realocacao_de_adiantamento, conciliamento_para: conciliamento)}
  let(:pessoa){presenca_direito_reposicao_com_justificativa.pessoa}

  it "Verifica se é a mesma pessoa nas duas presenças" do
    expect(presenca_direito_reposicao_com_justificativa.pessoa).to eq(presenca_realocacao_adiantamento.pessoa)
  end

  it "Valida para a justificativa não vir vazia" do
    expect(presenca_direito_reposicao_com_justificativa).not_to be_nil
  end

  it "Eh adiantamento na data?" do
    expect(pessoa.presencas.eh_adiantamento_na_data?(presenca_direito_reposicao_com_justificativa.data)).not_to be_empty
  end

  describe "Vinculo do adiantamento com a falta com direito a reposição" do
    it "Cria um adiantamento" do
      expect(presenca_direito_reposicao_com_justificativa.conciliamento_de.conciliamento_condition).to be_a(Adiantamento)
    end

    it "Cria apenas um adiantamento" do
      expect(Adiantamento.count).not_to be_zero
    end

    it "Cria apenas um conciliamento" do
      expect(Conciliamento.count).not_to be_zero
    end

    it "Verifica se a reposição cria um novo conciliamento" do
      expect(presenca_realocacao_adiantamento)
    end

    it "Não deve criar uma repoisção" do
      expect(Reposicao.count).to be_zero 
    end

    it "Vincula a presença com direito a reposição com justificativa com a presença de realocação" do
      expect(presenca_realocacao_adiantamento.conciliamento_para.para_id).to eq(presenca_realocacao_adiantamento.id)
    end
  end
end
