FactoryGirl.define do
  factory :presenca do
    pessoa
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
  end
end
