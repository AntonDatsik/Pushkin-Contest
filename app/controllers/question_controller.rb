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
    
    re = Regexp.new line
    $poems.find {|e| re =~ e["text"]}["title"]
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
    file = File.read("db/poems-full.json")
    @hash = JSON.parse(file)

    q = UnicodeUtils.downcase(line).lstrip.rstrip
    answer = ''
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
    sort_q = q.chars.sort

    temp_str = ""
    answer = ''
    @hash.each do |k| 

       k[1].each do |str|
          temp_str = str
          str = UnicodeUtils.downcase(str.delete(",").delete(";")).lstrip.rstrip

          if str.chars.sort == sort_q
             answer = temp_str
             return answer
          end     
       end
    end
    answer
  end

  def level8(temp_question)

    file = File.read("db/poems-full-sort.json")
    @hash = JSON.parse(file)


    q = temp_question.chars.sort.join.gsub(/[^0-9А-Яа-я]/, '')
    q_array = q.chars

    @hash.each do |k| 
      k[1].each do |str|

        str_parts = str.split("&")
        sort_part = str_parts[0]
        original_part = str_parts[1]

        # if sort_part.length != q.length
        #   break
        # end

        matches_count = 0


        sort_part_array = sort_part.chars

        i = 0
        while i < sort_part.length and matches_count <= 6 do
          if q_array[i] != sort_part_array[i]
            break
          else
            matches_count += 1
          end
          i += 1
        end
        
        if matches_count >= 6 then
          return original_part.delete(",").delete(".").delete("!").delete("?")
        end
      end
    end
  'default'
  end

end
