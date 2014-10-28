FactoryGirl.define do
  factory :horario_de_aula do
    horario "11:00"  
    dia_da_semana 2

    after(:build) do |instance, evaluator|
      FactoryGirl.create(:matricula) if Matricula.count == 0
      instance.matricula ||= Matricula.first
    end
  end
end
