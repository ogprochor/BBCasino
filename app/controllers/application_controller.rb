class ApplicationController < ActionController::Base
  # Uruchamiane przed każdą akcją w kontrolerach Devise (rejestracja, logowanie, edycja konta)
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Metoda rozszerzająca dozwolone parametry Devise podczas rejestracji i aktualizacji konta
  def configure_permitted_parameters
    # Pozwól na dodatkowe pola: username (nazwa użytkownika) oraz avatar (zdjęcie profilowe)
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :avatar])
  end
end
