# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe Reposicao, type: :model do
  let!(:presenca_direito_reposicao){FactoryGirl.create(:presenca, :direito_a_reposicao)}
  let(:conciliamento){presenca_direito_reposicao.conciliamento_de}
  let(:presenca_realocacao){FactoryGirl.create(:presenca, :realocacao, conciliamento_para: conciliamento)}
  let(:pessoa){presenca_direito_reposicao.pessoa}

  it "Verifica se existe conciliamento em aberto" do
    expect(pessoa.presencas.reposicao_ou_adiantamento_com_conciliamentos_em_aberto).not_to be_empty 
  end

  describe "vinculo da reposição com as presenças" do
    it "Cria uma reposição apartir de uma falta com direito a reposição" do
      expect(presenca_direito_reposicao.conciliamento_de.conciliamento_condition).to be_a(Reposicao)
    end

    it "Criar apenas uma Reposição" do
      expect(Reposicao.count).not_to be_zero 
    end

    it "Não deve criar um Adiantamento" do
      expect(Adiantamento.count).to be_zero
    end

    it "Vincula a presença com direito a reposição com a realocação" do
      expect(presenca_realocacao.conciliamento_para.para_id).to eq(presenca_realocacao.id)
    end
  end
end
