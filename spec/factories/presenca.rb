# -*- encoding : utf-8 -*-
#encoding: utf-8
FactoryGirl.define do
  factory :presenca do
    horario "08:00"
    data Time.now
    presenca true

    trait :direito_a_reposicao do
      presenca false
      tem_direito_a_reposicao true
      horario "07:00"
    end

    trait :realocacao do
      realocacao true
      horario "09:00"
    end

    trait :realocacao_de_adiantamento do
      realocacao true
      horario "10:00"
    end

    trait :direito_a_reposicao_de_adiantamento do
      presenca false
      tem_direito_a_reposicao true
      horario "07:00"
    end

    trait :com_justificativa_adiantado do
      association :justificativa_de_falta, descricao: "adiantado para o dia #{Time.now} às 10:00"
    end

    trait :aula_extra do
      aula_extra true
    end

    after(:build) do |instance, evaluator|
      FactoryGirl.create(:pessoa) if Pessoa.count == 0
      instance.pessoa ||= Pessoa.first
    end
  end
end
