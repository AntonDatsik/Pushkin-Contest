class QuestionController < ApplicationController
  skip_before_action :verify_authenticity_token

  def registration
    q = params[:question]
    @token = Token.new(token: params[:token])
    @token.save
    file = File.read("db/poems-full.json")
    hash = JSON.parse(file)
    @answer = 'снежные'
    render json: {answer: @answer}
  end


  def quiz
    render nothing: true

    @question = params[:question]
    @id = params[:id]
    @level = params[:level]

    @answer= ''
    case @level
    when 1
      @answer = level1(@question)
    when 2
      @answer = level2(@question)
    when 3
      @answer = level3(@question)
    when 4
      @answer = level4(@question)
    when 5
      @answer = level5(@question)
    when 6
      @answer = level6(@question)
    when 7
      @answer = level7(@question)
    when 8 
      @answer = level8(@question)
    end
    
    @token = Token.first.token
    uri = URI("http://pushkin.rubyroid.by/quiz")

    parameters = {
      answer: @answer,
      token: @token,
      task_id:  @id
    }
   
    Net::HTTP.post_form(uri, parameters) 
  end

  def level1(line)
    f = File.open( "db/poems.json", "r" )
    $poems = JSON.load( f )
    
    re = Regexp.new line.lstrip.rstrip
    answer = $poems.find {|e| re =~ e["text"]}["title"]
    answer
  end

  
  def level2(line)
    f = File.open( "db/poems.json", "r" )
    $poems = JSON.load( f )
    re = Regexp.new line.gsub('%WORD%', '([А-Яа-я]+)')
    poem = $poems.find {|e| re =~ e["text"]}
    re.match(poem["text"])[1]
  end

  def level3(lines)
    f = File.open( "db/poems.json", "r" )
    $poems = JSON.load( f )
    temp = lines.split("\n")

    line1 = temp[0]
    line2 = temp[1]

    re = Regexp.new line1.gsub('%WORD%', '([А-Яа-я]+)')
    poem = $poems.find {|e| re =~ e["text"]}
    temp_answer1 = re.match(poem["text"])[1]

    poem_text = poem["text"]
    re = Regexp.new line2.gsub('%WORD%', '([А-Яа-я]+)')
    temp_answer2 = re.match(poem_text)[1]

    answer = temp_answer1 + ',' + temp_answer2
  end

  def level4(lines)
    f = File.open( "db/poems.json", "r" )
    $poems = JSON.load( f )
    temp = lines.split("\n")

    line1 = temp[0]
    line2 = temp[1]
    line3 = temp[2]

    re = Regexp.new line1.gsub('%WORD%', '([А-Яа-я]+)')
    poem = $poems.find {|e| re =~ e["text"]}
    temp_answer1 = re.match(poem["text"])[1]

    poem_text = poem["text"]

    re = Regexp.new line2.gsub('%WORD%', '([А-Яа-я]+)')
    temp_answer2 = re.match(poem_text)[1]

    re = Regexp.new line3.gsub('%WORD%', '([А-Яа-я]+)')
    temp_answer3 = re.match(poem_text)[1]

    answer = temp_answer1 + ',' + temp_answer2 + ',' + temp_answer3
  end

  def level5(line)
    q = UnicodeUtils.downcase(@q).lstrip.rstrip

    question = q.split(" ")

    @hash.each do |k| 
      k[1].each do |str|
        if question.count > 2
           str = UnicodeUtils.downcase(str)
           if (str.include?(question[1]) && str.include?(question[2])) || (str.include?(question[0]) && str.include?(question[1])) || (str.include?(question[0]) && str.include?(question[2]))
              answer = (str.split(" ") - question)[0].delete(",") + "," + (question - str.split(" "))[0].delete(",")  
              return answer
           end         
        end
      end
    end
    answer
  end

  def level6(temp_question)
    file = File.read("db/poems-full.json")
    @hash = JSON.parse(file)

    q = UnicodeUtils.downcase(temp_question).lstrip.rstrip.delete(";").delete(",")
    answer = ''
    temp_str = ""

    @hash.each do |k| 
       k[1].each do |str|
          temp_str = str
          str = UnicodeUtils.downcase(str.delete(",").delete(";")).lstrip.rstrip
          if str.chars.sort == q.chars.sort
             answer = temp_str
             return answer
          end     
       end
    end
    answer
  end

  def level7(temp_question)

    file = File.read("db/poems-full.json")
    @hash = JSON.parse(file)

    q = UnicodeUtils.downcase(temp_question).lstrip.rstrip.delete(";").delete(",")

    temp_str = ""

    @hash.each do |k| 

       k[1].each do |str|
          temp_str = str
          str = UnicodeUtils.downcase(str.delete(",").delete(";")).lstrip.rstrip

          if str.chars.sort == q.chars.sort
             answer = temp_str
             return answer
          end     
       end
    end

  end

  def level8(temp_question)

    file = File.read("db/poems-full.json")
    @hash = JSON.parse(file)

    q = UnicodeUtils.downcase(temp_question).lstrip.rstrip.delete(";").delete(",")

    temp_str = ""

    @hash.each do |k| 

      k[1].each do |str|
        temp_str = str
        k = 0
        str = UnicodeUtils.downcase(str.delete(",").delete(";")).lstrip.rstrip

        for i in 0..str.chars.count-1 do
           if str.chars.sort[i] == q.chars.sort[i]
              k = k + 1
           end

           if k > 7
              answer = temp_str
              return answer
           end

        end
      end
    end

  end

end
