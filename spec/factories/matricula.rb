FactoryGirl.define do
  factory :matricula do
    pessoa
    data_inicio Time.now
  end
end
