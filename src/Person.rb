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
    
          /searchPerson - search person
          personDetails - view person details
          measureInfo - view list of all measures
          goalInfo - view list of goals
          currentMeasureList - view list of current measure
          p -checkMeasureList - view list of given measure
          p -verifyGoal - check if goal achieved
          p -comparisonValue - comparison value of current measure and goal
          p -cMeasure <name> <value> - create new measure
          p -cGoal <type> <value> <starDateGoal> 
                        <endDateGoal><achieved> - create new goal
          p -cPerson <firstname> <lastname> <birthdate> 
                          <email> <gender> - create new person
          pDelete <idPerson> - delete a person'
    help
  end

  #RestClient.post "http://example.com/resource", { 'x' => 1 }.to_json, :content_type => :json, :accept => :json
  # create person method
  public

  def createPerson(firstname,lastname,birthdate,email,gender)
    addr = @bls_addr.to_s

    puts addr
    puts "Inside the method createPerson !!! "
    sez = {'firstname' => firstname,'lastname' => lastname,'birthdate' => birthdate,'email' => email,'gender' => gender}
    puts sez
    response = RestClient.post addr.to_s, {'firstname' => firstname,'lastname' => lastname,'birthdate' => birthdate,'email' => email,'gender' => gender}.to_json,
    :content_type => :json, :accept => 'application/json'
    
    puts response
    newPerson = response.to_s
    puts "Id new person: " + newPerson.to_s
    text = "Id new person: " + newPerson.to_s
    return text
  end

  # create goal method
  public

  def createGoal(personId,type,value,startDateGoal,endDateGoal,achieved)
    addr = @bls_addr.to_s + personId.to_s + "/goal"
    puts addr
    puts "Inside the method createGoal !!! "

    sez = {'type' => type,'value' => value,'startDateGoal' => startDateGoal,'endDateGoal' => endDateGoal,'achieved' => achieved}
    puts sez
    response = RestClient.post addr.to_s, {'type' => type,'value' => value,'startDateGoal' => startDateGoal,'endDateGoal' => endDateGoal,'achieved' => achieved}.to_json,
    :content_type => :json, :accept => 'application/json'

    puts response
    newGid = response.to_s
    puts "Id new goal: " + newGid.to_s

    #calls checkNewGoal method --> PCS
    addr = @pcs_addr.to_s + personId.to_s + "/checkNewGoal/" + newGid.to_s
    puts addr
    puts "Inside the method checkNewGoal !!! "

    response = RestClient.get addr
    result = JSON.parse(response)
    newGoal = result["newGoal"]
    text = "Goal: " + newGoal['name'].to_s + "\n Type: " + newGoal['type'].to_s + "\n Value: " + newGoal['value'].to_s + "\n StartDateGoal: " + newGoal['startDateGoal'].to_s + "\n EndDateGoal: " + newGoal['endDateGoal'].to_s + "\n Achieved: " + newGoal['achieved'].to_s
    return text
  end

  # create measure method
  public

  def createMeasure(personId,name,value)
    #calls createMeasure method --> SS
    addr = @bls_addr.to_s + personId.to_s + "/measure"
    puts addr
    puts "Inside the method createMeasure !!! "

    sez = {'name' => name,'value' => value}
    puts sez
    response = RestClient.post addr.to_s, {'name' => name,'value' => value}.to_json,
    :content_type => :json, :accept => 'application/json'

    puts response
    newMid = response.to_s
    puts "Id new measure: " + newMid.to_s

    #calls checkNewMeasure method --> PCS
    addr = @pcs_addr.to_s + personId.to_s + "/checkNewMeasure/" + newMid.to_s
    puts addr
    puts "Inside the method checkNewMeasure !!! "

    response = RestClient.get addr
    result = JSON.parse(response)
    newMeasure = result["newMeasure"]
    text = "Measure: " + newMeasure['name'].to_s + "\n Type: " + newMeasure['type'].to_s + "\n Value: " + newMeasure['value'].to_s + "\n Created: " + newMeasure['created'].to_s
    return text
  end

  # view person Details method
  public

  def viewPersonDetails(personId)
    addr = @bls_addr.to_s + personId.to_s
    puts addr
    puts "Inside the method viewPersonDetails !!! "
    response = RestClient.get addr
    puts response

    person = JSON.parse(response)
    text = "Firstname: "+person['firstname']+"\n Lastname: "+person['lastname']+ "\n Birthdate: "+ person['birthdate']+"\n Email: "+person['email']+"\n Gender: "+person['gender']
    return text
  end

  # view list of goal method
  public

  def showListGoal(personId)
    addr = @bls_addr.to_s + personId.to_s+"/goal"
    puts addr
    puts "Inside the method showListGoal !!! "

    response = RestClient.get addr
    if response.code == 200
      puts response
      result = JSON.parse(response)
      x=result['goal']
      if !x.empty?
        text = " "
        x.each do |el|
          text << "\n Goal: " + el['type'].to_s + "\n Value: " + el['value'].to_s + "\n Start Date: " + el['startDateGoal'].to_s + "\n End Date: " + el['endDateGoal'].to_s + "\n Achieved: " + el['achieved'].to_s + " \n "
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
    puts "Inside the method view list of measure definition !!! "
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
    addr = @bls_addr.to_s + personId.to_s+"/current-health"
    puts addr
    puts "Inside the method view list of current measure !!! "
    response = RestClient.get addr
    puts response

    result = JSON.parse(response)
    puts result
    currentHealth = result['currentHealth-profile']
    measure = currentHealth['measure']
    text = " "
    measure.each do |el|
      text << "\n Measure: "+el['name'].to_s + "\n Value: "+el['value'].to_s + "\n Created: "+el['created'].to_s + "\n"
    end
    return text
  end

  # view list of history measure method
  public

  def showListHistoryHealth(personId)
    addr = @bls_addr.to_s + personId.to_s+"/history-health"
    puts addr
    puts "Inside the method view list of history measure !!! "
    response = RestClient.get addr
    puts response

    result = JSON.parse(response)
    puts result
    historyHealth = result['historyHealth-profile']
    measure = historyHealth['measure']
    text = " "
    measure.each do |el|
      text << "\n Measure: "+el['name'].to_s + "\n Value: "+el['value'].to_s + "\n Created: "+el['created'].to_s + "\n"
    end
    return text
  end

  # view list of a given measure
  public

  def checkMeasureList(personId,measureName)
    addr = @bls_addr.to_s + personId.to_s + "/measure/"+ measureName.to_s
    puts addr
    puts "Inside the method check list of a given measure !!! "
    response = RestClient.get addr
    puts response

    result = JSON.parse(response)
    puts result
    measureProfile = result['measure-profile']
    measure = measureProfile['measure']
    text = "Measure: " + measureName.to_s + "\n"
    measure.each do |el|
      text << "\n Mid: " + el['mid'].to_s + "\n Value: " + el['value'].to_s + "\n Created: " + el['created'].to_s + "\n"
    end
    return text
  end

  #Delete person method
  public

  def deletePerson(personId)
    addr = @bls_addr.to_s + personId.to_s
    puts addr
    puts "Inside the method deletePerson !!! "
    response = RestClient.delete addr
    if response.code === 204
      text = "Person with " + personId.to_s + " deleted."
    else
      text = "Person with " + personId.to_s + " does not exist."  
    end
  end


  # comparison information about measure and goal method
  public

  def comparisonValue(personId,measureName)
    addr = @pcs_addr + personId.to_s + "/comparisonValue/" + measureName.to_s
    puts addr
    puts "Inside the method getComparisonValue !!! "
    response = RestClient.get addr
    puts response

    result = JSON.parse(response)
    info = result['info']
    measure = info['measure']
    goal = info['goal']
    comparison = info['comparison']
    text = " "
    text << "\n Measure: " + measure['name'].to_s + "\n Type: " + measure['type'].to_s + "\n Value: " + measure['value'].to_s + "\n" +
    "\n Goal: " + goal['name'].to_s + "\n Value: " + goal['value'].to_s + "\n Achieved: " + goal['achieved'].to_s + "\n" +
    "\n Result: " + comparison['result'].to_s + "\n Quote: " + comparison['quote'].to_s
    return text
  end

  # verify if goal achieved
  public

  def verifyGoal(personId,measureName)
    addr = @pcs_addr + personId.to_s + "/verifyGoal/" + measureName
    puts addr
    puts "Inside the method verifyGoal !!! "
    response = RestClient.get addr
    puts response

    result = JSON.parse(response)
    check = result['verifyGoal']
    goal = check['goal']
    text = " "
    text << "\n Goal: " + goal['name'].to_s + "\n Type: " + goal['type'].to_s + "\n Value: " + goal['value'].to_s + "\n Achieved: " + goal['achieved'].to_s + "\n Motivation: " + goal['motivation'].to_s
    return text
  end

  def bls_addr
    @bls_addr
  end

  def bls_addr=(bls)
    @bls_addr=bls
  end

end