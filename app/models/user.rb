# Model reprezentujący użytkownika kasyna
# Obsługuje uwierzytelnianie i rejestrację przez Devise
class User < ApplicationRecord
  # Moduły Devise:
  # - database_authenticatable: logowanie przez email i hasło
  # - registerable: możliwość rejestracji nowych użytkowników
  # - recoverable: resetowanie hasła przez email
  # - rememberable: zapamiętywanie sesji użytkownika
  # - validatable: podstawowa walidacja emaila i hasła
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Każdy użytkownik posiada jedno powiązane konto/wallet przechowujące saldo
  has_one :wallet

  # Po utworzeniu użytkownika automatycznie inicjalizujemy portfel z domyślnym saldem
  after_create :initialize_wallet

  # Obsługa załącznika (np. awatar użytkownika) przy pomocy Active Storage
  has_one_attached :avatar

  # Historia zmian salda użytkownika (np. zakłady, wypłaty, bonusy)
  has_many :balance_histories

  private

  # Metoda tworząca portfel użytkownika z początkowym saldem 1000 żetonów
  def initialize_wallet
    create_wallet(balance: 1000)  # Domyślne saldo startowe
  end
end
