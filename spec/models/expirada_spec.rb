require 'rails_helper'

RSpec.describe Expirada, :type => :model do 
  let(:expirada){FactoryGirl.build(:expirada)}
  let(:matricula){
    FactoryGirl.create(:matricula, horario_de_aula: [FactoryGirl.create(:horario_de_aula)])
  }
  let!(:presenca_direito_reposicao){FactoryGirl.create(:presenca, :direito_a_reposicao)}
  let(:horario_de_aula){matricula.horario_de_aula}
  let(:pessoa){matricula.pessoa}

  it "Cria Expirada" do
    expect(expirada).to be_valid
  end

  it "Cria Matricula" do
    expect(matricula).to be_valid
  end

  it "Cria Horário de Aula" do
    expect(novo_horario_de_aula).to be_valid
  end

  describe "Criar com direito a reposição além do limite máximo de repor, validando o método expira reposições" do
    before{
      (1..5).each do 
        FactoryGirl.create(:presenca, :direito_a_reposicao)
      end
    } 

    it "Verificar se criou a presença para mesma pessoa" do   
      Presenca.all.each do |presenca|
        expect(presenca.pessoa).to eq(pessoa)
      end
    end

    it "Verifica se criou o horário de aula com a mesma matricula" do
      HorarioDeAula.all.each do |horario_de_aula|
        expect(horario_de_aula.matricula).to eq(horario_de_aula)
      end
    end

    it "Validar scope que verifica os conciliamentos abertos" do
      pessoa.presencas.com_conciliamentos_em_aberto.each do |presenca_com_conciliamento_em_aberto|
        expect(presenca_com_conciliamento_em_aberto.conciliamento_de.para_id).to be_nil
      end
    end

    it "Validar scope que excuta o count máximo de reposições" do
      p matricula.count_maximo_reposicoes    
    end
  end
end
