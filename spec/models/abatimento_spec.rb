require 'rails_helper'

RSpec.describe Abatimento, :type => :model do
  let!(:presenca_com_aula_extra){FactoryGirl.create(:presenca, :aula_extra)}
  let(:conciliamento){presenca_com_aula_extra.conciliamento_de}
  let(:presenca_com_direito){FactoryGirl.create(:presenca, :direito_a_reposicao, conciliamento_para: conciliamento)}
  let(:pessoa){presenca_com_aula_extra.pessoa}

  it "Cria a presença com aula extra" do
    expect(presenca_com_aula_extra).to be_valid
  end

  describe "Vinculos do abatimento" do
    it "Cria o Conciliamento do tipo abatimento" do
      expect(presenca_com_aula_extra.conciliamento_de.conciliamento_condition).to be_a(Abatimento)
    end
    
    it "Cria apenas um Abatimento" do
      expect(Abatimento.count).not_to be_zero
    end
    
    it "Vincula a aula extra com falta com direito a reposição" do
      expect(presenca_com_direito.conciliamento_para.para_id).to eq(presenca_com_direito.id)
    end

    it "Com conciliamento em aberto?" do
      expect(pessoa.presencas.com_conciliamentos_em_aberto.eh_abatimento).not_to be_empty
    end
  end
end
