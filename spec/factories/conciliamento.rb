FactoryGirl.define do
  factory :conciliamento do
    after(:build) do |instance, evaluator|
      instance.de_id = FactoryGirl.create(:presenca, :direito_a_reposicao).id
    end
  end
end
