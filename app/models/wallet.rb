# Model reprezentujący portfel użytkownika
# Przechowuje aktualne saldo środków (żetonów) gracza
class Wallet < ApplicationRecord
  # Powiązanie z użytkownikiem, do którego należy portfel
  belongs_to :user

  # Możesz tu dodać metody np. do aktualizacji salda,
  # obsługi depozytów i wypłat, jeśli będą potrzebne
end
