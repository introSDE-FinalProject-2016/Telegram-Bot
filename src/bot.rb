require 'telegram/bot'
require 'rest-client'
require 'pp'
require 'faraday'

require_relative 'Person'

token = '217842946:AAFyBzppkNaN70JXGlQzXVTBB9XVwKnfCc4'

$id_Person = 0
$measureName = ""
$mode = "json"

puts ' ------------------------------------   '
puts '      STARTING THE INTROSDE-BOT         '
puts ' ------------------------------------   '

# Storage Services
ss_addr = "https://warm-hamlet-95336.herokuapp.com/sdelab/storage-service/person/"
# Business Logic Services
bls_addr = "https://fierce-sea-36005.herokuapp.com/sdelab/businessLogic-service/person/"

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text

    #**************************** START - STOP - HELP ********************************************
    when '/start'
      puts 'Inside start command...'
      question = '
       Welcome, to LIFESTYLE COACH APP!

       The App allows the user to
       visualize, modify and add its
       personal information and
       to register the goals and lifestyle
       measurements. It will help you
       to control your everyday
       physical activity and
       hydration.

       Send searchPerson to begin
       the application. You can create
       a new person or can find your id
       checking the list of people in the
       database.
       Tell the bot to /stop when
       you are done.
       Send /help if you want to see
       the menu.'

      answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [%w(searchPerson peopleList), %w(createNewPerson)], one_time_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)

    when '/stop'
      puts 'Inside stop command...'
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: 'Sorry to see you go :(', reply_markup: kb)

    when '/help'
      puts 'Inside help command...'
      obj_person = Person.new
      obj_person.help()
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: obj_person.help(), reply_markup: kb)

      #**************************** LOGIN ********************************************

    when 'searchPerson'
      ask_id = "Insert your id: p=<id>"
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: ask_id, reply_markup: kb)

      #Check id for person
    when /p=\d+/
      id = message.text.match(/\d+/)[0].to_i
      $id_Person = id
      puts "Id person: " + $id_Person.to_s

      response = RestClient.get bls_addr + $id_Person.to_s
      puts response

      person = JSON.parse(response)

      if response.code != 200
        error_message = "Wrong id... Please search your id."
        bot.api.send_message(chat_id: message.chat.id, text: error_message)

      else
        welcome_message = "Welcome, "
        text = welcome_message + person['lastname'] + " " + person['firstname'] + "!\nPlease, choose an operation from the MENU below to proceed."

        answers_user = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['/help', '/stop'],
          ['personInfo', 'measureInfo',  'goalInfo'],
          ['currentMeasureList', 'findMeasureByName'],
          ['createNewMeasure', 'checkAchievedGoals'],
          ['createNewGoal', 'deletePerson']], one_time_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: answers_user)
      end

      #**************************** PERSON ********************************************

    when 'createNewPerson'
      ask_id = "Insert your personal information: p -cPerson <firstname> <lastname> <birthdate> <email> <gender>"
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: ask_id, reply_markup: kb)

      #Create new person
      #p -cPerson Jack Lambert 2000-12-10 hgjfoe@hotmail.com M
    when /p\s-cPerson/
      puts 'Inside createNewPerson method...'

      b=message.text.gsub(/\s+/m, ' ').strip.split(" ")
      puts "Size of b: " + b.size.to_s

      if b.size === 7
        firstname = b[2]
        lastname = b[3]
        birthdate = b[4]
        email = b[5]
        gender = b[6]

        puts "Firstname: " + firstname
        puts "Lastname: " + lastname
        puts "Birthdate: " + birthdate
        puts "Email: " + email
        puts "Gender: " + gender

        obj_person = Person.new()
        text = obj_person.createPerson(firstname,lastname,birthdate,email,gender)
        puts "Response of method post in bot: "+ text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      else
        puts "You just making it up!"
      end

      #Get list of people
    when 'peopleList'
      puts 'Inside peopleList method that show the list of people...'
      obj_person = Person.new()
      text = obj_person.viewPeopleListDetails
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      #Create new goal
    when 'createNewGoal'
      ask_id = "Insert a new goal: p -cGoal <type> <value> <condition>"
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: ask_id, reply_markup: kb)

      #p -cGoal water 4 <
    when /p\s-cGoal/
      puts 'IdPerson: ' + $id_Person.to_s
      if $id_Person == 0
        $id_Person = 1
      end

      puts 'Inside createNewGoal method for a specified person with id=' + $id_Person.to_s
      b=message.text.gsub(/\s+/m, ' ').strip.split(" ")
      puts "Size of b: " + b.size.to_s
      if b.size === 5
        type = b[2]
        value = b[3]
        condition = b[4]

        puts "Type: " + type
        puts "Value: " + value
        puts "Condition: " + condition
        obj_person = Person.new()
        text = obj_person.createGoal($id_Person,type,value,condition)
        puts "Response of method post in bot: "+ text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      else
        puts "You just making it up!"
      end

      #Create new measure
    when 'createNewMeasure'
      ask_id = "Insert a new measure: p -cMeasure <name> <value>"
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: ask_id, reply_markup: kb)

      #p -cMeasure water 4
    when /p\s-cMeasure/
      puts 'IdPerson: ' + $id_Person.to_s
      if $id_Person == 0
        $id_Person = 1
      end

      puts 'Inside createNewMeasure method for a specified person with id=' + $id_Person.to_s
      b=message.text.gsub(/\s+/m, ' ').strip.split(" ")
      puts "Size of b " + b.size.to_s
      if b.size === 4
        name = b[2]
        value = b[3]

        puts "Name: " + name
        puts "Value: " + value
        obj_person = Person.new()
        text = obj_person.createMeasure($id_Person,name,value)
        puts "Response of method post in bot: "+ text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      else
        puts "You just making it up!"
      end

      #show person info
    when 'personInfo'
      puts 'IdPerson: ' + $id_Person.to_s
      if $id_Person != 0
        puts 'Inside personInfo method for a specified person with id=' + $id_Person.to_s
        obj_person = Person.new()
        text = obj_person.viewPersonDetails($id_Person)
        puts text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      end

      #Get list of goal
    when 'goalInfo'
      puts 'IdPerson: ' + $id_Person.to_s
      if $id_Person != 0
        puts 'Inside goalInfo method for a specified person with id=' + $id_Person.to_s
        obj_person = Person.new()
        text = obj_person.showListGoal($id_Person)
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      end

      #Get list of measure types
    when 'measureDefinition'
      puts 'Inside measureDefinitionList method...'
      obj_person = Person.new()
      text = obj_person.showMeasureDefinition
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      #Get list of current measure
    when 'currentMeasureList'
      puts 'IdPerson: ' + $id_Person.to_s
      if $id_Person == 0
        $id_Person = 1
      end

      puts 'Inside currentMeasureList method for a specified person with id=' + $id_Person.to_s
      obj_person = Person.new()
      text = obj_person.showListCurrentHealth($id_Person)
      puts text.to_s
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      #Get list of history measure
    when 'measureInfo'
      puts 'IdPerson: ' + $id_Person.to_s
      if $id_Person == 0
        $id_Person = 1
      end

      puts 'Inside HistoryMeasureList method for a specified person with id=' + $id_Person.to_s
      obj_person = Person.new()
      text = obj_person.showListHistoryHealth($id_Person)
      puts text.to_s
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

    when 'findMeasureByName'
      puts 'IdPerson: ' + $id_Person.to_s
      if $id_Person != 0
        puts 'Inside findMeasureByName method for a specified person with id=' + $id_Person.to_s
        ask_id = "Insert measure's name to search: p -fMeasureByName <measureName>"
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: ask_id, reply_markup: kb)
      end
    
      #p -cMeasureByName weight
    when /p\s-fMeasureByName/
      puts 'IdPerson: ' + $id_Person.to_s
      if $id_Person == 0
        $id_Person = 1
      end

      b = message.text.gsub(/\s+/m, ' ').strip.split(" ")
      puts "Size of b: " + b.size.to_s
      
      if b.size === 3
        measureName = b[2]
        puts "MeasureName: " + measureName
      
        obj_person = Person.new()
        text = obj_person.checkMeasureByMeasureName($id_Person,measureName)
        puts text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      end  

    when 'deletePerson'
      ask_id = "Insert an id to delete: pDelete <id>"
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: ask_id, reply_markup: kb)

      #Delete Person
      #pDelete <idPerson>
    when /pDelete \d+/
      id = message.text.match(/\d+/)[0].to_i
      if id != 0
        puts 'Inside deletePerson method...'

        obj_person = Person.new()
        text = obj_person.deletePerson(id)
        puts text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      end

      #check if at least one goal achieved
    when 'checkAchievedGoals'
      puts 'IdPerson: ' + $id_Person.to_s
      if $id_Person != 0
        puts 'Inside checkAchievedGoals method for a specified person with id=' + $id_Person.to_s
        obj_person = Person.new()
        text = obj_person.countGoalsAchieved($id_Person)
        puts text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new(text, 'image/jpeg'))
        #bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      end  
      
    end
  end
end