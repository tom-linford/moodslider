require 'nokogiri'

class WelcomeController < ApplicationController
  # initialise recommendations and sliders
  $shows = nil
  $calm = 50
  $sad = 50
  $awake = 50
  $fearless = 50

  def moodslider
  end

  def upload
  end

  def update
    # retrieve slider values using Ajax
    $calm = params[:calm].to_i
    $sad = params[:sad].to_i
    $awake = params[:awake].to_i
    $fearless = params[:fearless].to_i

    # select the dominant mood for each slider
    # if the slider value is too 'neutral', no recommendations are shown
    mood = $calm <= 50 ? 'Agitated' : 'Calm'
    calm = ($calm > 45 && $calm < 55) ? nil : Show.where(mood: mood).first
    mood = $sad <= 50 ? 'Happy' : 'Sad'
    sad = ($sad > 45 && $sad < 55) ? nil : Show.where(mood: mood).first
    mood = $awake <= 50 ? 'Tired' : 'Wide Awake'
    awake = ($awake > 45 && $awake < 55) ? nil : Show.where(mood: mood).first
    mood = $fearless <= 50 ? 'Scared' : 'Fearless'
    fearless = ($fearless > 45 && $fearless < 55) ? nil : Show.where(mood: mood).first

    # retrieve the maximum slider value (in either direction)
    max = get_max

    # determine the strongest mood based on the maximum value
    # if the maximum value is also 'neutral', no mood is strongest
    if max <= 45 || max >= 55
      if $calm.equal? max
        mood = ($calm <= 50) ? 'Agitated' : 'Calm'
      else if $sad.equal? max
             mood = ($sad <= 50) ? 'Happy' : 'Sad'
           else if $awake.equal? max
                  mood = ($awake <= 50) ? 'Tired' : 'Wide Awake'
                else
                  mood = ($fearless <= 50) ? 'Scared' : 'Fearless'
                end
           end
      end
      # get the second recommendation for the strongest mood
      # as the first recommendation will already be shown
      strongest = Show.where(mood: mood).limit(2)[1]
    else
      strongest = nil;
    end

    $shows = [calm, sad, awake, fearless, strongest]
    redirect_to root_path
  end

  def get_file
    file_data = params[:file]
    # if the uploaded file can be read
    if file_data.respond_to?(:read)
      file = file_data.read
      parse file
    elsif file_data.respond_to?(:path)
      file = File.read(file_data.path)
      parse file
    else
      # the file cannot be read, log an error
      logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
    end
    redirect_to root_path
  end

private

  def parse(file)
    # refresh the list of shows
    Show.delete_all
    xml = Nokogiri::XML(file)
    # loop through all 'programme' tags and create a new table record
    xml.css('programme').each do |prog|
      Show.create!(
          :name => prog.css('name').text.to_s,
          :path => prog.css('image').text.to_s,
          :mood => prog.css('mood').text.to_s
      )
    end
    # clear the recommendations
    $shows = []
  end

  def get_max
    # determine the most extreme slider value (in either direction)
    vals = [$calm, $sad, $awake, $fearless]
    strengths = vals.map { |n| (n - 50).abs }
    max = strengths.max
    vals[strengths.find_index max]
  end
end
