class GamesController < ApplicationController
  # Akcja wyświetlająca stronę ruletki
  def roulette
  end

  # Akcja obsługująca spin ruletki
  def spin_roulette
    chosen = params[:choice]              # Wybrany przez gracza kolor lub numer
    bet = params[:bet].to_i.clamp(1, 1_000_000)  # Kwota zakładu (od 1 do 1 mln)

    number = rand(37)                    # Losowanie liczby 0-36 (0 = zielony)
    color = number == 0 ? "zielony" : number.even? ? "czarny" : "czerwony"

    win = 0
    result = ""

    if current_user&.wallet
      # Odejmij zakład od salda
      current_user.wallet.decrement!(:balance, bet)
      BalanceHistory.create(user: current_user, amount: -bet, reason: "Ruletka bet")

      if chosen == color
        # Wygrana za trafienie koloru - podwójna stawka
        win = bet * 2
        current_user.wallet.increment!(:balance, win)
        BalanceHistory.create(user: current_user, amount: win, reason: "Ruletka wygrana")
        result = "✅ Trafiłeś kolor #{color}! Wygrywasz #{win} żetonów!"
      elsif chosen.to_i.to_s == chosen && chosen.to_i == number
        # Wygrana za trafienie numeru - 36x stawka
        win = bet * 36
        current_user.wallet.increment!(:balance, win)
        BalanceHistory.create(user: current_user, amount: win, reason: "Ruletka wygrana")
        result = "🎯 Trafiłeś numer #{number}! Wygrywasz #{win} żetonów!"
      else
        # Przegrana
        result = "❌ Wypadło #{number} (#{color}). Niestety, przegrywasz."
      end
    else
      result = "Brak środków lub niezalogowany."
    end

    logger.info "🎲 spin_roulette start"
    logger.info "🎲 Wybrano: #{chosen}, Bet: #{bet}"
    logger.info "🎯 Wypadło: #{number} (#{color})"

    @result = result
    @number = number
    @color = color

    respond_to do |format|
      format.html { render :roulette }    # render widoku ruletki
      format.turbo_stream                 # obsługa Turbo Streams (np. AJAX)
    end

    puts "🔁 Parametry ruletki: #{params.inspect}"
    puts "➡️  Wynik: #{@result}"
  end

  # Autoryzacja - dostęp do gier blackjack tylko dla zalogowanych
  before_action :authenticate_user!, only: [:blackjack_deal, :blackjack_hit, :blackjack_stand]

  # Widok blackjacka (pokaż aktualną rozgrywkę z sesji)
  def blackjack
    @player_cards = session[:player_cards] || []
    @dealer_cards = session[:dealer_cards] || []
    @result = session[:blackjack_result]
  end

  # Rozpoczęcie rozdania w blackjacku
  def blackjack_deal
    bet = params[:bet].to_i.clamp(1, 1000)

    if current_user.wallet.balance < bet
      flash[:alert] = "❌ Za mało środków!"
      redirect_to blackjack_path and return
    end

    # Odejmij kwotę zakładu od salda użytkownika
    current_user.wallet.decrement!(:balance, bet)
    BalanceHistory.create(user: current_user, amount: -bet, reason: "BlackJack start")

    # Zapisz zakład i wyczyść wynik z sesji
    session[:bet] = bet
    session[:blackjack_result] = nil

    # Przygotuj talię kart (4 talie kart od 2 do 11)
    deck = (2..11).to_a * 4
    deck.shuffle!
    session[:deck] = deck

    # Rozdaj po 2 karty graczowi i dealerowi
    session[:player_cards] = [deck.pop, deck.pop]
    session[:dealer_cards] = [deck.pop, deck.pop]

    redirect_to blackjack_path
  end

  # Gracz dobiera kartę (hit)
  def blackjack_hit
    session[:player_cards] << rand(2..11)  # Dodaj losową kartę od 2 do 11

    if session[:player_cards].sum > 21
      # Jeśli przekroczono 21, gracz przegrywa
      session[:blackjack_result] = "💥 Przegrałeś! Masz ponad 21."
    end

    redirect_to blackjack_path
  end

  # Gracz stoi (stand) - dealer dobiera karty aż do minimum 17
  def blackjack_stand
    while session[:dealer_cards].sum < 17
      session[:dealer_cards] << rand(2..11)
    end

    player_total = session[:player_cards].sum
    dealer_total = session[:dealer_cards].sum

    # Określenie wyniku gry
    if dealer_total > 21 || player_total > dealer_total
      session[:blackjack_result] = "🎉 Wygrałeś!"
    elsif dealer_total == player_total
      session[:blackjack_result] = "🤝 Remis!"
    else
      session[:blackjack_result] = "❌ Przegrałeś!"
    end

    redirect_to blackjack_path
  end

  # Akcja wyświetlająca i obsługująca sloty (jednoręki bandyta)
  def slots
    puts "⚙️ SLOTY: weszliśmy do metody"

    # Definicja symboli z wagami i nagrodami
    symbol_pool = [
      ['🍒', 5, 10],
      ['🍋', 5, 15],
      ['🍊', 4, 20],
      ['🍉', 3, 30],
      ['🍇', 3, 40],
      ['💎', 2, 100],
      ['7️⃣', 1, 200]
    ]

    # Tworzymy listę symboli zgodnie z wagą (większa waga = większa szansa)
    weighted_symbols = symbol_pool.flat_map { |sym, weight, _| [sym] * weight }

    # Losujemy 3 symbole
    @symbols = weighted_symbols.sample(3)

    counts = @symbols.tally
    max_count = counts.values.max
    winning_symbol = counts.key(max_count)

    # Pobierz dane symbolu: nagrodę za pojedynczy symbol
    symbol_data = symbol_pool.find { |s| s[0] == winning_symbol }
    reward = symbol_data ? symbol_data[2] : 0

    # Określ wynik na podstawie ilości trafionych symboli
    @result =
      case max_count
      when 3
        "🎉 JACKPOT! Trzy #{winning_symbol} – wygrywasz #{reward * 3} żetonów!"
      when 2
        "😊 Dwa #{winning_symbol} – wygrywasz #{reward} żetonów!"
      else
        "😞 Nic nie trafiłeś. Spróbuj ponownie!"
      end

    if current_user && current_user.wallet
      case max_count
      when 3
        current_user.wallet.increment!(:balance, reward * 3)
        BalanceHistory.create(user: current_user, amount: reward * 3, reason: "Slot wygrana")
      when 2
        current_user.wallet.increment!(:balance, reward)
        BalanceHistory.create(user: current_user, amount: reward, reason: "Slot wygrana")
      else
        # Koszt gry: 10 żetonów
        current_user.wallet.decrement!(:balance, 10)
        BalanceHistory.create(user: current_user, amount: -10, reason: "Slot przegrana")
      end
    end

    puts "🎰 Wylosowano symbole: #{@symbols.inspect}"
    puts "👛 Saldo: #{current_user.wallet.balance}" if current_user&.wallet

    respond_to do |format|
      format.html { render :slots }      # render strony slotów
      format.turbo_stream                # obsługa Turbo Streams
    end
  end
end
