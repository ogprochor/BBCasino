# Model administratora panelu zarządzania systemem kasyna
# Korzysta z Devise do obsługi uwierzytelniania i odzyskiwania hasła
class AdminUser < ApplicationRecord
  # Włącza moduły Devise odpowiedzialne za:
  # - logowanie na podstawie e-maila i hasła (database_authenticatable)
  # - resetowanie hasła przez e-mail (recoverable)
  # - zapamiętywanie sesji między logowaniami (rememberable)
  # - walidację poprawności e-maila i hasła (validatable)
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable

  # Pozwala na filtrowanie i wyszukiwanie atrybutów przez gem Ransack
  # Umożliwia np. przeszukiwanie użytkowników po emailu, ID, czy dacie utworzenia
  def self.ransackable_attributes(auth_object = nil)
    [
      "email",
      "created_at",
      "updated_at",
      "id",
      "reset_password_sent_at",
      "reset_password_token",
      "remember_created_at"
    ]
  end
end
