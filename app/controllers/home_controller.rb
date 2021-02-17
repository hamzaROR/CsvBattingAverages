class HomeController < ApplicationController
  require 'csv'
  

  def upload_csv
  	#Function to upload csv file from user.
	file = params[:my_file].read
	filename = params[:my_file].original_filename
	File.open(File.join('public', "Batting.csv"), 'wb') { |f| f.write file }
	redirect_to root_path
  end

  def index
  	#If file is already loaded then read that file instaed of waiting for new file, temp saving file
  	if File.file?("#{Rails.public_path}/Batting.csv")
  		@check = true
	  	players = {}
	  	team_array = {}
	  	@team_names = []
	  	@years = []
	  	@teams = CSV.read("public/Teams.csv")
		#creating hash of all the team names so we map there name easily
	  	@teams.each do |row|
	  		team_array[row[2]] = {id: row[2], name: row[11]}			
	  	end
	  	@players_details = CSV.read("public/Batting.csv")
	  	@players_details.drop(1).each do |row|

			#creating hash of all the team names and years so we can show in dropdown on index page
	  		@years << row[1]
	  		@team_names << team_array[row[3]][:name]
				if row[2] != "1"
	  			if row[8].to_f == 0.0 
	  	  			average = '0.000'
				else
		  			average = '%.3f' % (row[6].to_f/row[8].to_f)
	  			end
	  			num = row[2].to_f
	  			average = '%.3f' % ( ( (players[row[0]+"_"+row[1]][:average].to_f * (num - 1)) + average.to_f ) / num )
		  		players[row[0]+"_"+row[1]] = {id: row[0], year: row[1], teams: players[row[0]+"_"+row[1]][:teams] + "," + row[3], average: average}			
				else
	  			if row[8].to_f == 0.0 
	  	  			average = '0.000'
				else
		  			average = '%.3f' % (row[6].to_f/row[8].to_f)
	  			end
		  		players[row[0]+"_"+row[1]] = {id: row[0], year: row[1], teams: team_array[row[3]][:name], average: average}			
			end  				
	  	end

		#sorting players on average values	
	  	@players_details = players.sort_by{|k,v| v[:average].to_i}.reverse

	  	#filter players if year is present
		if params[:year].present?
			@players_details = @players_details.select {|x| x.last[:year] == params[:year]}
		end

	  	#filter players if team_name is present
		if params[:team_name].present?
			@players_details = @players_details.select {|x| x.last[:teams] == params[:team_name]}
		end
	  	@years = @years.uniq
	  	@team_names = @team_names.uniq  		
  	else
  		@check = false  		
  		@players_details = []
  	end  	
  end
end

