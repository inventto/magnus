FactoryGirl.define do
  factory :presenca do
    horario "08:00"
    data Time.now
    presenca true

    trait :direito_a_reposicao do
      presenca false
      tem_direito_a_reposicao true
    end

    trait :realocacao do
      presenca true
      realocacao true
    end

    after(:build) do |instance, evaluator|
      FactoryGirl.create(:pessoa) if Pessoa.count == 0
      instance.pessoa ||= Pessoa.first
    end
  end
end
