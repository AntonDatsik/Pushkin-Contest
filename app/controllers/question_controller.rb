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
    # render nothing: true

    @question = params[:question]
    @id = params[:id]
    @level = params[:level]

    @answer= ''
    case @level
    when '1'
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
    
    @token = Token.last.token
    uri = URI("http://pushkin.rubyroid.by/quiz")

    parameters = {
      answer: @answer,
      token: @token,
      task_id:  @id
    }
   
    # Net::HTTP.post_form(uri, parameters) 
    render json: {answer: @answer}
  end

  private
  # def level1(question)

  #   file = File.read("db/poems-full.json")
  #   @hash = JSON.parse(file)

  #   question = UnicodeUtils.downcase(question.lstrip.rstrip)
  #   answer = ''
  #   @hash.each do |k|     
  #     k[1].map do |str|
  #       arr = question.split(" ")
  #       question = arr[arr.count-2] + " " + arr[arr.count-1]
  #       str = UnicodeUtils.downcase(str)
  #       if str.include?(question) then
  #         answer = k[0].lstrip.rstrip
  #         return answer
  #       end
  #     end
  #   end
  # end

  def level1(line)
    f = File.open( "db/poems.json", "r" )
    $poems = JSON.load( f )
    
    re = Regexp.new line.lstrip.rstrip
    answer = $poems.find {|e| re =~ e["text"]}["title"]
    answer.slice(0, answer.length)
  end

  def level2(temp_question)

    file = File.read("db/poems-full.json")
    @hash = JSON.parse(file)

    answer = ''
    question = temp_question.split("%word%")
    question = question.map do |i|
      i = UnicodeUtils.downcase(i.delete("!").delete(",").lstrip.rstrip)
    end

    temp_str = []
    temp_q = temp_question.split(" ")
    temp_q = temp_q.map do |s|
      s = s.delete(",").delete("!")
    end

    @hash.each do |k| 
      k[1].map do |str|
        str = str.delete(".")
        if question.count >= 2
          str = UnicodeUtils.downcase(str.delete(",").delete("!").delete("."))
          if str.include?(question[0]) && str.include?(question[1])

              temp_str = str.split(" ")
              temp_str = temp_str.map do |s|
                s = UnicodeUtils.downcase(s.delete(",").delete("!").delete("."))
              end
              answer = UnicodeUtils.downcase((temp_str - temp_q)[0].to_s.delete("?").delete("!"))
              return answer
          end 
        elsif question.count < 2
          str = UnicodeUtils.downcase(str.delete(",").delete("!").delete("."))
          if str.include?(question[0]) 
              temp_str = str.split(" ")
              temp_str = temp_str.map do |s|
                s = UnicodeUtils.downcase(s.delete(",").delete("!").delete("."))
              end
              answer = UnicodeUtils.downcase((temp_str - temp_q)[0].to_s.delete("?").delete("!"))
              return answer
          end 
        end
      end
    end  

    answer
  end

  # def level3(question)
  #   answer = ''
  #   temp = question.split('\n')
  #   q1 = temp[0]
  #   q2 = temp[1]
  #   q1.downcase!
  #   q2.downcase!
  #   q = q1.split('word')


  #   @hash.each do |k|
  #     for index in 0..k[1].count - 1  
  #       str = k[1][index]
  #       str.downcase!
  #       if q.count >= 2 then
  #         if str.include?(q[0]) || str.include?(q[1]) then
  #           question_words = q1.split(" ")
  #           str_words = str.split(" ")
              
  #           for i in 0..str_words.count - 1 
  #             if !str_words[i].eql?(question_words[i])
  #               answer = str_words[i].delete(",").delete(".").delete("?")
  #               answer += ','
  #               answer += next_line_with_word(k[1][index+1], q2)
  #               return answer
  #             end
  #           end
  #         else
  #           if str.include?(q[0]) then
  #             question_words = q1.split(" ")
  #             str_words = str.split(" ")

  #             for i in 0..str_words.count - 1 
  #               if !str_words[i].eql?(question_words[i])
  #                 answer = str_words[i].delete(",").delete(".").delete("?")
  #                 answer += ','
  #                 answer += next_line_with_word(k[1][index+1], q2)
  #                 return answer
  #               end
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end
  #   answer
  # end

  # def next_line_with_word(str, q)
  #   answer = ''
  #   str.downcase!
  #   question = q
  #   q = q.split("word")

  #   if q.count >= 2 then
  #     if str.include?(q[0]) || str.include?(q[1]) then
  #       question_words = question.split(" ")
  #       str_words = str.split(" ")
                
  #       for i in 0..str_words.count - 1 
  #         if !str_words[i].eql?(question_words[i])
  #           answer = str_words[i].delete(",").delete(".").delete("?")
  #           return answer
  #         end
  #       end
  #     end
  #   else
  #     if str.include?(q[0]) then
  #       question_words = question.split(" ")
  #       str_words = str.split(" ")

  #       for i in 0..str_words.count - 1 
  #         if !str_words[i].eql?(question_words[i])
  #           answer = str_words[i].delete(",").delete(".").delete("?")
  #           return answer
  #         end
  #       end
  #     end
  #   end
  #   answer
  # end

  def level3(temp_question)

    file = File.read("db/poems-full.json")
    @hash = JSON.parse(file)

    q = UnicodeUtils.downcase(temp_question).lstrip.rstrip.split("\n")

    answer = []

    q.map do |que|
    que = que.delete(".").lstrip.rstrip
    @hash.each do |k| 

    question = que.split("%word%")
    question = question.map do |i|
      i = UnicodeUtils.downcase(i.delete("!").delete(",").lstrip.rstrip)
    end

    temp_str = []
    temp_q = que.split(" ")
    temp_q = temp_q.map do |s|
      s = s.delete(",").delete("!")
    end 

       k[1].each do |str|
        if question.count >= 2
          str = UnicodeUtils.downcase(str.delete(",").delete("!").delete("."))
          if str.include?(question[0]) && str.include?(question[1])

              temp_str = str.split(" ")
              temp_str = temp_str.map do |s|
                s = UnicodeUtils.downcase(s.delete(",").delete("!").delete("."))
              end
              answer << UnicodeUtils.downcase((temp_str - temp_q)[0].to_s.delete("?").delete("!"))
          end 
        elsif question.count < 2
          str = UnicodeUtils.downcase(str.delete(",").delete("!").delete("."))
          if str.include?(question[0]) 
              temp_str = str.split(" ")
              temp_str = temp_str.map do |s|
                s = UnicodeUtils.downcase(s.delete(",").delete("!").delete("."))
              end
              answer << UnicodeUtils.downcase((temp_str - temp_q)[0].to_s.delete("?").delete("!"))
          end 
        end
       end

    end
    end

    answer = answer.uniq
    answer = answer.join(",")
    return answer.to_s
  end

  def level4(temp_question)

    file = File.read("db/poems-full.json")
    @hash = JSON.parse(file)

    q = UnicodeUtils.downcase(temp_question).lstrip.rstrip.split("\n")

    answer = []

    q.map do |que|
    que = que.delete(".").lstrip.rstrip
    @hash.each do |k| 

    question = que.split("%word%")
    question = question.map do |i|
      i = UnicodeUtils.downcase(i.delete("!").delete(",").lstrip.rstrip)
    end

    temp_str = []
    temp_q = que.split(" ")
    temp_q = temp_q.map do |s|
      s = s.delete(",").delete("!")
    end 

       k[1].each do |str|
        if question.count >= 2
          str = UnicodeUtils.downcase(str.delete(",").delete("!").delete("."))
          if str.include?(question[0]) && str.include?(question[1])

              temp_str = str.split(" ")
              temp_str = temp_str.map do |s|
                s = UnicodeUtils.downcase(s.delete(",").delete("!").delete("."))
              end
              answer << UnicodeUtils.downcase((temp_str - temp_q)[0].to_s.delete("?").delete("!"))
          end 
        elsif question.count < 2
          str = UnicodeUtils.downcase(str.delete(",").delete("!").delete("."))
          if str.include?(question[0]) 
              temp_str = str.split(" ")
              temp_str = temp_str.map do |s|
                s = UnicodeUtils.downcase(s.delete(",").delete("!").delete("."))
              end
              answer << UnicodeUtils.downcase((temp_str - temp_q)[0].to_s.delete("?").delete("!"))
          end 
        end
       end

    end
    end

    answer = answer.uniq
    answer = answer.join(",")
  end

  def level5(temp_question)

    file = File.read("db/poems-full.json")
    @hash = JSON.parse(file)

    answer = ''
    q = UnicodeUtils.downcase(temp_question).lstrip.rstrip

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
