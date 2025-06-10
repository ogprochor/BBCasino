# Bazowa klasa dla wszystkich modeli ActiveRecord w aplikacji
# Dzięki niej można centralnie definiować zachowania dziedziczone przez inne modele
# (np. wspólne metody, walidacje, hooki, konfiguracje itp.)
class ApplicationRecord < ActiveRecord::Base
  # Oznacza, że ta klasa nie ma odpowiadającej jej tabeli w bazie danych
  # i służy wyłącznie jako klasa abstrakcyjna
  primary_abstract_class
end
