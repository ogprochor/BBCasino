class UsersController < ApplicationController
  # Akcja wyświetlająca stronę konta użytkownika
  # Pobiera historię zmian salda użytkownika, posortowaną rosnąco według daty
  def account
    @balance_history = current_user.balance_histories.order(:created_at)
  end
end
