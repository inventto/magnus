require 'rails_helper'

RSpec.describe Reposicao, type: :model do
  let!(:presenca_direito_reposicao){FactoryGirl.create(:presenca, :direito_a_reposicao)}
  let(:conciliamento){presenca_direito_reposicao.conciliamento_de}
  let!(:presenca_realocacao){FactoryGirl.create(:presenca, :realocacao, conciliamento_para: conciliamento)}

  describe "vinculo da reposição com as presenças" do
    it "Cria uma reposição apartir de uma falta com direito a reposição" do
      expect(presenca_direito_reposicao.conciliamento_de.conciliamento_condition).to be_a(Reposicao)
    end

    it "Completar conciliamento com a realocação" do
      expect(presenca_realocacao.conciliamento_para.para_id).to eq(presenca_realocacao.id)
    end
  end
end
