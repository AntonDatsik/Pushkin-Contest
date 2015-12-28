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
    file = File.read("db/poems-full.json")
    @hash = JSON.parse(file)
    @answer = ""
    case @level
    when '1'
      @answer = level1(@question)
    when '2'
      @answer = level2(@question)
    when '3'
      @answer = level3(@question)
    end
    
    @token = Token.last.token
    uri = URI("http://pushkin.rubyroid.by/quiz")

    parameters = {
      answer: @answer,
      token: @token,
      task_id:  @id
    }

    Net::HTTP.post_form(uri, parameters) 
  end

  private
  def level1(question)
    question.lstrip.rstrip.downcase!
    answer = ''
    @hash.each do |k|
      k[0] = k[0].delete("!")
      
      k[1].map do |str|
        str.downcase!
        if str.include?(question) then
          answer = UnicodeUtils.downcase(k[0]).lstrip.rstrip
          break
        end
      end
    end
    answer
  end

  def level2(question)
    answer = ''
    question.downcase!
    q = question.split('%word%')

    @hash.each do |k|
      k[1].map do |str|
        str.downcase!
        if q.count >= 2 then
          if str.include?(q[0]) || str.include?(q[1]) then
            question_words = question.split(" ")
            str_words = str.split(" ")
              
            for i in 0..str_words.count - 1 
              if !str_words[i].eql?(question_words[i])
                answer = str_words[i].delete(",").delete(".").delete("?")
                return answer
              end
            end
          else
            if str.include?(q[0]) then
              question_words = question.split(" ")
              str_words = str.split(" ")

              for i in 0..str_words.count - 1 
                if !str_words[i].eql?(question_words[i])
                  answer = str_words[i].delete(",").delete(".").delete("?")
                  return answer
                end
              end
            end
          end
        end
      end
    end

    answer
  end

  def level3(question)
    answer = ''
    temp = question.split('\n')
    q1 = temp[0]
    q2 = temp[1]
    q1.downcase!
    q2.downcase!
    q = q1.split('word')


    @hash.each do |k|
      for index in 0..k[1].count - 1  
        str = k[1][index]
        str.downcase!
        if q.count >= 2 then
          if str.include?(q[0]) || str.include?(q[1]) then
            question_words = q1.split(" ")
            str_words = str.split(" ")
              
            for i in 0..str_words.count - 1 
              if !str_words[i].eql?(question_words[i])
                answer = str_words[i].delete(",").delete(".").delete("?")
                answer += ','
                answer += next_line_with_word(k[1][index+1], q2)
                return answer
              end
            end
          else
            if str.include?(q[0]) then
              question_words = q1.split(" ")
              str_words = str.split(" ")

              for i in 0..str_words.count - 1 
                if !str_words[i].eql?(question_words[i])
                  answer = str_words[i].delete(",").delete(".").delete("?")
                  answer += ','
                  answer += next_line_with_word(k[1][index+1], q2)
                  return answer
                end
              end
            end
          end
        end
      end
    end
    answer
  end

  def next_line_with_word(str, q)
    answer = ''
    str.downcase!
    question = q
    q = q.split("word")

    if q.count >= 2 then
      if str.include?(q[0]) || str.include?(q[1]) then
        question_words = question.split(" ")
        str_words = str.split(" ")
                
        for i in 0..str_words.count - 1 
          if !str_words[i].eql?(question_words[i])
            answer = str_words[i].delete(",").delete(".").delete("?")
            return answer
          end
        end
      end
    else
      if str.include?(q[0]) then
        question_words = question.split(" ")
        str_words = str.split(" ")

        for i in 0..str_words.count - 1 
          if !str_words[i].eql?(question_words[i])
            answer = str_words[i].delete(",").delete(".").delete("?")
            return answer
          end
        end
      end
    end
    answer
  end

  def level4
  end

  def level5
  end
end
