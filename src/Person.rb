class Person
  def initialize
    #post/get method
    @bls_addr = "https://fierce-sea-36005.herokuapp.com/sdelab/businessLogic-service/person/"
    @bls_measureDef_addr = "https://fierce-sea-36005.herokuapp.com/sdelab/businessLogic-service/measureDefinition";

    #post method
    @pcs_addr = "https://desolate-thicket-56593.herokuapp.com/sdelab/processCentric-service/person/"
  end

  def help()
    help= '
          You can control me by sending these commands:

          searchPerson - search a person by id
          createPerson - create new person
          peopleListDetails - view the list of people into DB
          personDetails - view person details
          measureInfo - view list of measures
          goalInfo - view list of goals
          currentMeasureList - view list of current measure
          checkMeasureList - view list measure for a given measureName
          createNewMeasure - create new measure and check if goal achieved
          p -comparisonValue - comparison value of current measure and goal
          createNewMeasure - create new measure
          createNewGoal - create new goal
          deletePerson - delete a person'
    help
  end

  
  #RestClient.post "http://example.com/resource", { 'x' => 1 }.to_json, :content_type => :json, :accept => :json
  # create person method
  public

  def createPerson(firstname,lastname,birthdate,email,gender)
    addr = @bls_addr.to_s
    puts addr

    puts 'BLS --> Inside the createNewPerson method...'

    sez = {'firstname' => firstname,'lastname' => lastname,'birthdate' => birthdate,'email' => email,'gender' => gender}
    puts sez
    response = RestClient.post addr.to_s, {'firstname' => firstname,'lastname' => lastname,'birthdate' => birthdate,'email' => email,'gender' => gender}.to_json,
    :content_type => :json, :accept => 'application/json'
    puts response

    newPerson = response.to_s
    puts "Id new person: " + newPerson.to_s
    welcome_message = "Welcome, "
    text = welcome_message + lastname + " " + firstname + "!.\n Your id is : " + newPerson.to_s
    return text
  end

  
  # create goal method
  public

  def createGoal(personId,type,value,condition)
    addr = @bls_addr.to_s + personId.to_s + "/goal"
    puts addr

    puts 'BLS --> Inside the createNewGoal method...'

    sez = {'type' => type,'value' => value,'condition' => condition}
    puts sez
    response = RestClient.post addr.to_s, {'type' => type,'value' => value,'condition' => condition}.to_json,
    :content_type => :json, :accept => 'application/json'
    puts response

    newGid = response.to_s
    puts "Id new goal: " + newGid.to_s

    #calls checkNewGoal method --> PCS
    addr = @pcs_addr.to_s + personId.to_s + "/checkNewGoal/" + newGid.to_s
    puts addr
    puts 'PCS --> Inside the checkNewGoal method ...'

    response = RestClient.get addr
    result = JSON.parse(response)
    text = "Goal: " + result['type'].to_s + "\n ID: " + result['gid'].to_s + "\n Value: " + result['value'].to_s + "\n StartDateGoal: " + result['startDateGoal'].to_s + "\n EndDateGoal: " + result['endDateGoal'].to_s + "\n Achieved: " + result['achieved'].to_s + "\n Condition: " + result['condition'].to_s
    return text
  end

  
  # view person Details method
  public

  def viewPersonDetails(personId)
    addr = @bls_addr.to_s + personId.to_s
    puts addr

    puts 'BLS --> Inside the viewPersonDetails method...'
    response = RestClient.get addr
    puts response

    result = JSON.parse(response)
    text = "\n Firstname: " + result['firstname'].to_s + "\n Lastname: " + result['lastname'].to_s + "\n Birthdate: " + result['birthdate'].to_s + "\n Email: " + result['email'].to_s + "\n Gender: " + result['gender'].to_s
    return text
  end

  
  # view list of goal method
  public

  def showListGoal(personId)
    addr = @bls_addr.to_s + personId.to_s + "/goal"
    puts addr

    puts 'BLS --> Inside the showListGoal method...'

    response = RestClient.get addr
    if response.code == 200
      puts response
      result = JSON.parse(response)
      x=result['goal']
      if !x.empty?
        text = "List of goals: \n"
        x.each do |el|
          text << "\n Id: " + el['gid'].to_s + "\n Type: " + el['type'].to_s + "\n Value: " + el['value'].to_s + "\n Start Date: " + el['startDateGoal'].to_s + "\n End Date: " + el['endDateGoal'].to_s + "\n Achieved: " + el['achieved'].to_s + "\n Condition: " + el['condition'].to_s + " \n "
        end
      else
        text = "There are not goals"
      end
    else
      text = "Error"
    end
    return text
  end

  
  # view list of measure types method
  public

  def showMeasureDefinition
    addr = @bls_measureDef_addr
    puts addr

    puts 'BLS --> Inside the viewListMeasureDefinition method...'
    response = RestClient.get addr
    puts response

    result = JSON.parse(response)
    puts result
    measureNames = result['measureNames']
    measureName = measureNames['measureName']
    text = " "
    measureName.each do |el|
      text << "\n MeasureName: " + el
    end
    return text
  end

  
  # view list of current measure method
  public

  def showListCurrentHealth(personId)
    addr = @bls_addr.to_s + personId.to_s + "/current-health"
    puts addr

    puts 'BLS --> Inside the showListCurrentMeasure method...'

    response = RestClient.get addr
    puts response

    if response.code == 200
      puts response
      result = JSON.parse(response)
      x=result['measure']
      if !x.empty?
        text = "List of current measures:\n"
        x.each do |el|
          text << "\n Id: "+el['mid'].to_s + "\n Name: "+el['name'].to_s + "\n Value: "+el['value'].to_s + "\n Created: "+el['created'].to_s + "\n"
        end
      else
        text = "There are not measures"
      end
    else
      text = "Error"
    end
    return text
  end

  
  # view list of history measure method
  public

  def showListHistoryHealth(personId)
    addr = @bls_addr.to_s + personId.to_s+"/history-health"
    puts addr

    puts 'BLS --> Inside the showListHistoryMeasure method...'

    response = RestClient.get addr
    puts response

    if response.code == 200
      puts response
      result = JSON.parse(response)
      x=result['measure']
      if !x.empty?
        text = "List of history measures:\n"
        x.each do |el|
          text << "\n Id: "+el['mid'].to_s + "\n Name: "+el['name'].to_s + "\n Value: "+el['value'].to_s + "\n Created: "+el['created'].to_s + "\n"
        end
      else
        text = "There are not measures"
      end
    else
      text = "Error"
    end
    return text
  end

  
  # view list of a given measure
  public

  def checkMeasureByMeasureName(personId,measureName)
    addr = @bls_addr.to_s + personId.to_s + "/measure/" + measureName.to_s
    puts addr

    puts 'BLS --> Inside the checkMeasureByMeasureName method...'

    response = RestClient.get addr
    puts response

    result = JSON.parse(response)
    puts result
    measure = result['measure']
    text = "Measure: " + measureName.to_s + "\n"
    measure.each do |el|
      text << "\n Id: " + el['mid'].to_s + "\n Value: " + el['value'].to_s + "\n Created: " + el['created'].to_s + "\n"
    end
    return text
  end

  
  #Delete person method
  public

  def deletePerson(personId)
    addr = @bls_addr.to_s + personId.to_s
    puts addr

    puts 'BLS --> Inside the deletePerson method...'

    response = RestClient.delete addr
    if response.code == 200
      text = "\n Person with " + personId.to_s + " deleted."
    else
      text = "\n Person with " + personId.to_s + " does not exist."
    end
  end

  
  # count achieved goals for a specified person with idPerson
  public

  def countGoalsAchieved(personId)
    addr = @pcs_addr + personId.to_s + "/goals"
    puts addr

    puts 'PCS --> Inside the countGoalsAchieved method'

    response = RestClient.get addr
    puts response
    result = JSON.parse(response)
    puts "Result json" + result.to_s
    text = result['url'].to_s
    new_str = text.slice(0..(text.index('?')-1))
    puts "New URL: " + new_str    
    return new_str
  end

  
  # insert new measure and check if goal achieved
  public

  def createMeasure(personId,name,value)
    addr = @pcs_addr.to_s + personId.to_s + "/measure"
    puts addr
    puts 'PCS --> Inside the inserNewMeasure method...'

    response = RestClient.get addr, :params => {:name => name, :value => value}
    result = JSON.parse(response)

    puts "Result json" + result.to_s

    x = result['currentHealth']
    y = x['measure']
    measure = "List of current measure:\n"  
    text = result['phrase'].to_s + "\n" + 
           "\n" + measure
    
    y.each do |el|
      text << "\n Id: "+el['mid'].to_s + "\n Name: "+el['name'].to_s + "\n Value: "+el['value'].to_s + "\n Created: "+el['created'].to_s + "\n"
    end

    return text
  end

  
  # view peopleList Details method
  public

  def viewPeopleListDetails
    addr = "https://fierce-sea-36005.herokuapp.com/sdelab/businessLogic-service/person"
    puts addr

    puts 'BLS --> Inside the viewPeopleListDetails method...'
    response = RestClient.get addr
    puts response

    if response.code == 200
      puts response
      result = JSON.parse(response)
      x=result['person']
      if !x.empty?
        text = " "
        x.each do |el|
          text << "\n Id: " + el['pid'].to_s + "\n Firstname: " + el['firstname'].to_s + "\n Lastname: " + el['lastname'].to_s + "\n Birthdate: " + el['birthdate'].to_s + "\n Email: " + el['email'].to_s + "\n Gender: " + el['gender'].to_s + "\n"
        end
      else
        text = "There are not measures"
      end
    else
      text = "Error"
    end
    return text
  end

  def bls_addr
    @bls_addr
  end

  def bls_addr=(bls)
    @bls_addr=bls
  end

end