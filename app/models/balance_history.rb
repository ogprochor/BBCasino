# Model odpowiadający za historię zmian salda użytkownika
# Rejestruje każdą operację finansową związaną z kontem gracza (np. wygrana, przegrana, bonus, wypłata)
class BalanceHistory < ApplicationRecord
  # Każda zmiana salda przypisana jest do konkretnego użytkownika
  belongs_to :user
end
