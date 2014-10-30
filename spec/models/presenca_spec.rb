require 'rails_helper'

RSpec.describe Presenca, type: :model do 
  let(:presenca_com_direito){FactoryGirl.create(:presenca, :direito_a_reposicao)}
  let(:realocacao){FactoryGirl.create(:presenca, :realocacao)}
  let(:reposicao_ou_adiantamento_com_conciliamento_aberto){Presenca.reposicao_ou_adiantamento_com_conciliamentos_em_aberto}

  it "Cria presença com direito a reposição" do
    expect(presenca_com_direito).to be_valid
  end

  it "Busca presenças com conciliamento aberto do tipo Reposição e adiantamento" do
    expect(reposicao_ou_adiantamento_com_conciliamento_aberto).not_to be_nil
  end
end
