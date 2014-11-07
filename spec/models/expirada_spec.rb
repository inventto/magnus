require 'rails_helper'

RSpec.describe Expirada, :type => :model do 
  let!(:matricula){
    FactoryGirl.create(:matricula, horario_de_aula: [FactoryGirl.create(:horario_de_aula)])
  }
  let!(:presenca_direito_reposicao){FactoryGirl.create(:presenca, :direito_a_reposicao)}
  let(:horario_de_aula){matricula.horario_de_aula}
  let(:pessoa){matricula.pessoa}

  it "Cria Matricula" do
    expect(matricula).to be_valid
  end

  it "Verifica se criou o conciliamento do tipo Reposição" do
    expect(presenca_direito_reposicao.conciliamento_de.conciliamento_condition).to be_a(Reposicao)
  end

  describe "Criar com direito a reposição além do limite máximo de repor, validando o método expira reposições" do
    let(:max_reposicoes_count){4}
    before{
      max_reposicoes_count.times.each do 
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
        expect(matricula.horario_de_aula.first).to eq(horario_de_aula)
      end
    end

    it "Validar scope que verifica os conciliamentos abertos" do
      pessoa.presencas.com_conciliamentos_em_aberto.each do |presenca_com_conciliamento_em_aberto|
        expect(presenca_com_conciliamento_em_aberto.conciliamento_de.para_id).to be_nil
      end
    end

    it "Validar scope que excuta o count máximo de reposições" do
      expect(matricula.count_maximo_reposicoes).to eq max_reposicoes_count    
    end

    it "Validar Matricula" do
      expect(pessoa.matriculas.valida.first).to eq(matricula)
    end

    it "Verifica se expirou a presença com direito a reposição" do
       expirada = pessoa.presencas.joins(:conciliamento_de).where("conciliamento_condition_type = 'Expirada'").first
       expect(expirada.conciliamento_de.conciliamento_condition).not_to be_nil 
    end
  end
end
