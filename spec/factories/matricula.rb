# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :matricula do
    data_inicio Time.now

    after(:build) do |instance, evaluator|
      FactoryGirl.create(:pessoa) if Pessoa.count == 0
      instance.pessoa ||= Pessoa.first
    end
  end
end
