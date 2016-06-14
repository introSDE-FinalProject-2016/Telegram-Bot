require 'telegram/bot'
require 'rest-client'
require 'pp'
require 'faraday'

require_relative 'Person'

token = '217842946:AAFyBzppkNaN70JXGlQzXVTBB9XVwKnfCc4'

$id_Person = 0
$measureName = ""
$mode = "json"

puts '---------------------------------'
puts 'Starting the bot...'
puts '---------------------------------'

# Storage Services
ss_addr = "https://warm-hamlet-95336.herokuapp.com/sdelab/storage-service/person/"
# Business Logic Services
bls_addr = "https://fierce-sea-36005.herokuapp.com/sdelab/businessLogic-service/person/"
# Process Centric Services

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text

    #**************************** START - STOP - HELP ********************************************
    when '/start'
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

       Send /searchPerson to begin 
       the application. You can create a
       new person.
       Tell the bot to /stop when
       you are done.
       Send /help if you want to see the menu.'

      answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [%w(/searchPerson)], one_time_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)
      #bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}", reply_markup: answers)

    when '/stop'
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: 'Sorry to see you go :(', reply_markup: kb)
      #bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")

    when '/help'
      obj_person = Person.new
      obj_person.help()
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: obj_person.help(), reply_markup: kb)

      #      #**************************** LOGIN ********************************************

    when '/searchPerson'
      ask_id = "Welcome: insert your p=<id>"
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: ask_id, reply_markup: kb)

      #Check id for person
    when /p=\d+/
      id = message.text.match(/\d+/)[0].to_i
      $id_Person = id
      puts "Id person: " + $id_Person.to_s
      puts id.to_s
      response = RestClient.get 'https://warm-hamlet-95336.herokuapp.com/sdelab/storage-service/person/'+$id_Person.to_s
      if response.code != 200
        error_message = "Wrong id... Please search your id."
        bot.api.send_message(chat_id: message.chat.id, text: error_message)
      else
        welcome_person = "Push personDetails button to receive last info about you"
        answers_user = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['welcome', '/help', '/stop'],
          ['personDetails', 'measureInfo',  'goalInfo'],
          ['currentMeasureList', 'p -checkMeasureList'],
          ['p -verifyGoal', 'p -comparisonValue'],
          ['p -cMeasure', 'p -cGoal', 'pDelete']], one_time_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: welcome_person, reply_markup: answers_user)
      end

      #**************************** PERSON ********************************************
      #Create new person
      #p -cPerson Jack Lambert 2000-12-10 hgjfoe@hotmail.com M
    when /p\s-cPerson/
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
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      else
        puts "You just making it up!"
      end

      #Create new goal
      #p -cGoal water 4 2016-05-09 2016-05-20 false
    when /p\s-cGoal/
      if $id_Person == 0
        $id_Person = 1
      end

      b=message.text.gsub(/\s+/m, ' ').strip.split(" ")
      puts "Size of b " + b.size.to_s
      if b.size === 7
        type = b[2]
        value = b[3]
        startDateGoal = b[4]
        endDateGoal = b[5]
        achieved = b[6]

        puts "Type: " + type
        puts "Value: " + value
        puts "StartDateGoal: " + startDateGoal
        puts "EndDateGoal: " + endDateGoal
        puts "Achieved: " + achieved
        obj_person = Person.new()
        text = obj_person.createGoal($id_Person,type,value,startDateGoal,endDateGoal,achieved)
        puts "Response of method post in bot: "+ text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      else
        puts "You just making it up!"
      end

      #Create new measure
      #p -cMeasure water 4
    when /p\s-cMeasure/
      if $id_Person == 0
        $id_Person = 1
      end

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

    when 'welcome'
      puts "Id person inside if welcome " + $id_Person.to_s
      welcome_message = "Welcome back, "
      response = RestClient.get 'https://warm-hamlet-95336.herokuapp.com/sdelab/storage-service/person/'+$id_Person.to_s
      person = JSON.parse(response)
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      text = welcome_message + person['lastname'] + ' ' + person['firstname'] + '!. Please, choose an operation from the MENU to proceed'
      bot.api.send_message(chat_id: message.chat.id, text: text , reply_markup: kb)

      #show person detail
    when 'personDetails'
      puts $id_Person != 0
      if $id_Person != 0
        puts "Id person inside if personInfo " + $id_Person.to_s
        obj_person = Person.new()
        text = obj_person.viewPersonDetails($id_Person)
        puts text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      end

      #Get list of goal
    when 'goalInfo'
      if $id_Person != 0
        puts 'Inside show list of goal...'
        obj_person = Person.new
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: obj_person.showListGoal($id_Person), reply_markup: kb)
      end

      #Get list of measure types
    when 'measureDefinition'
      puts 'Inside list of measure types'
      obj_person = Person.new
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: obj_person.showMeasureDefinition, reply_markup: kb)

      #Get list of current measure
    when 'currentMeasureList'
      if $id_Person == 0
        $id_Person = 1
      end

      puts 'Inside show list of current measure...'
      obj_person = Person.new()
      text = obj_person.showListCurrentHealth($id_Person)
      puts text.to_s
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      #Get list of history measure
    when 'measureInfo'
      if $id_Person == 0
        $id_Person = 1
      end

      puts 'Inside show list of history measure...'
      obj_person = Person.new()
      text = obj_person.showListHistoryHealth($id_Person)
      puts text.to_s
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      #p -checkMeasureList weight
    when /p\s-checkMeasureList/
      if $id_Person == 0
        $id_Person = 1
      end

      puts 'Inside check a list of a given measure method...'

      b=message.text.gsub(/\s+/m, ' ').strip.split(" ")
      puts "Size of b: " + b.size.to_s
      puts "b[2]: " + b[2]
      if b.size === 3
        measureName = b[2]
        puts "MeasureName: " + measureName
      end
      obj_person = Person.new()
      text = obj_person.checkMeasureList($id_Person,measureName)
      puts text.to_s
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      #p -comparisonInfo weight
    when /p\s-comparisonValue/
      if $id_Person == 0
        $id_Person = 1
      end

      puts 'Inside comparison value information method...'

      b=message.text.gsub(/\s+/m, ' ').strip.split(" ")
      puts "Size of b: " + b.size.to_s
      puts "b[2]: " + b[2]
      if b.size === 3
        measureName = b[2]
        puts "MeasureName: " + measureName
      end
      obj_person = Person.new()
      text = obj_person.comparisonValue($id_Person,measureName)
      puts text.to_s
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      #p -verifyGoal weight
    when /p\s-verifyGoal/
      if $id_Person == 0
        $id_Person = 1
      end

      puts 'Inside verify goal method...'

      b=message.text.gsub(/\s+/m, ' ').strip.split(" ")
      puts "Size of b: " + b.size.to_s
      puts "b[2]: " + b[2]
      if b.size === 3
        measureName = b[2]
        puts "MeasureName: " + measureName
      end
      obj_person = Person.new()
      text = obj_person.verifyGoal($id_Person,measureName)
      puts text.to_s
      kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)

      #Delete Person
      #pDelete <idPerson>
    when /pDelete \d+/
      id = message.text.match(/\d+/)[0].to_i
      if id != 0
        puts "Inside delete method"
        obj_person = Person.new()
        text = obj_person.deletePerson(id)
        puts text.to_s
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
        bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: kb)
      end

    end
  end
end