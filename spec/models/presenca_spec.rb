require 'rails_helper'

RSpec.describe Presenca, type: :model do 
  let!(:presenca_com_direito){FactoryGirl.create(:presenca, :direito_a_reposicao)}
  let(:realocacao){FactoryGirl.create(:presenca, :realocacao)}
  let(:reposicao_ou_adiantamento_com_conciliamento_aberto){Presenca.reposicao_ou_adiantamento_com_conciliamentos_em_aberto}
  let(:falta_com_direito_com_justificativa_adiantado){FactoryGirl.create(:presenca, :direito_a_reposicao_de_adiantamento, :com_justificativa_adiantado)}
  let(:presenca_com_aula_extra){FactoryGirl.create(:presenca, :aula_extra)}

  it "Cria presença com direito a reposição" do
    expect(presenca_com_direito).to be_valid
  end

  it "Busca presenças com conciliamento aberto do tipo Reposição e adiantamento" do
    expect(reposicao_ou_adiantamento_com_conciliamento_aberto).not_to be_nil
  end

  it "Cria Falta com direito a reposição e com justificativa de adiantamento" do
    expect(falta_com_direito_com_justificativa_adiantado).to be_valid
  end

  it "Cria a presença com aula extra" do
    expect(presenca_com_aula_extra).to be_valid
  end
end
