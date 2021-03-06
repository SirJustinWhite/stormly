class WelcomeController < ApplicationController
require 'forecast_io'

  def index


	
	skyconArrayLtd = ["PARTLY_CLOUDY_DAY", "CLEAR_DAY",
	  					"RAIN", "SLEET"]
	@randomSkyconLtd = skyconArrayLtd[rand(0..3)]
  end


	def currentlocation
		@numDays = 7 #set to 8 to add 'today' back 
		@numHours = 25

	  if cookies[:lat_lng]
		lat_lng = cookies[:lat_lng]
		    myLocation = lat_lng.to_s.split('|')
			ForecastIO.api_key = '489e6541e3f4c8d407a3152e17f8e8d3'  	

		@latitude   = myLocation[0]
	  	@longitude  = myLocation[1]
		forecast   = ForecastIO.forecast(@latitude, @longitude) 
	  	@timezone  = forecast.timezone
	  	result = Geocoder.search(@latitude+","+@longitude)


  		@myState = result[0].address_components[5]["short_name"]
		@myAddress = result[0].formatted_address
		cityType = result[0].address_components[2]["types"][0]
	  	if cityType == "neighborhood" 
	  		@myCity = result[0].address_components[3]["long_name"]
	  	else 
	  		@myCity = result[0].address_components[2]["short_name"]
	  	end		

 

	#Current Weather Data
	 	currentForecast 				= forecast.currently # gives you the current forecast datapoint
	 	@currentApparentTemp			= currentForecast.apparentTemperature.round.to_s + "°"
	 	@currentCloudCover				= (currentForecast.cloudCover * 100).to_i
	 	@currentDewPoint				= currentForecast.dewPoint.to_i
	 	@currentHumidity				= (currentForecast.humidity * 100).to_i
	 	@currentNearestStormBearing		= currentForecast.nearestStormBearing
	 	@currentNearestStormDistance	= currentForecast.nearestStormDistance.to_i
	 	@currentOzone					= currentForecast.ozone
	 	@currentPrecipIntensity			= currentForecast.precipIntensity.round(2)
	 	@currentPrecipProbability		= (currentForecast.precipProbability * 100).to_i
	 	@currentPressure				= currentForecast.pressure.to_i
		@currentSummary  				= currentForecast.summary.downcase 
		@minutelySummary				= forecast.minutely.summary.downcase.chomp(".")
		@currentTemp 	 				= currentForecast.temperature.round.to_s + "°"
	  	@currentTime 					= currentForecast.time
	  	@currentHour					= Time.at(currentForecast.time).hour
	  	@currentVisibility				= currentForecast.visibility
	  	@currentWindBearing				= currentForecast.windBearing
	  	@currentWindSpeed 				= currentForecast.windSpeed.to_i
	  	#Reformat forecast.io icon strings to be readable by skycons (upcase and underscores instead of dash)
	 	currentIcon					= currentForecast.icon.upcase
		if currentIcon 	  == "PARTLY-CLOUDY-DAY"
			@currentSkycon = "PARTLY_CLOUDY_DAY"
			@conditionBG   = "partlyCloudy" 

		elsif currentIcon == "PARTLY-CLOUDY-NIGHT"
			@currentSkycon = "PARTLY_CLOUDY_NIGHT"
			@conditionBG   = "midnightCloud"

		elsif currentIcon == "CLEAR-DAY"
			@currentSkycon = "CLEAR_DAY"
			@conditionBG   = "clearSky"

		elsif currentIcon == "CLEAR-NIGHT"
			@currentSkycon = "CLEAR_NIGHT"
			@conditionBG   = "midnight"

		elsif currentIcon == "CLOUDY"
			@currentSkycon = currentIcon
			@conditionBG   = "cloudy"

		elsif currentIcon == "RAIN"
			@currentSkycon = currentIcon
			@conditionBG   = "rain"

		elsif currentIcon == "SLEET"
			@currentSkycon = currentIcon
			@conditionBG   = "sleet" 

		elsif currentIcon == "SNOW"
			@currentSkycon = currentIcon
			@conditionBG   = "snow" #NEEDS NEW TEXT COLOR

		elsif currentIcon == "WIND"
			@currentSkycon = currentIcon
			@conditionBG   = "wind" #NEEDS A BETTER COLOR / ICON COLOR CONFLICT

		elsif currentIcon == "FOG"
			@currentSkycon = currentIcon
			@conditionBG   = "foggy"
		end

	#Daily Weather Data

		@dailyForecastJSON 	= forecast.daily
		dailyForecast 	 	= forecast.daily

	   index = 0
	    @dailySummary = [],  @dailyLoTemp =  [], @dailyHiTemp = [], @dailySummary = [], 
	    @dailyApparentLoTemp = [], @dailyApparentHiTemp = [], @dailyPrecipProb = [],
	    dailyIcon = [], @dailySkycon = [], @dailyTime = [], dailyMoonPhase = [], @dailyMoonPhaseName = []
	    	@weekSummary = dailyForecast.summary
	      8.times do
	        @dailySummary[index] 		= dailyForecast.data[index].summary
	        @dailyLoTemp[index] 		= dailyForecast.data[index].temperatureMin.round
	        @dailyHiTemp[index] 		= dailyForecast.data[index].temperatureMax.round
	        @dailyApparentLoTemp[index] = dailyForecast.data[index].apparentTemperatureMin.round
	        @dailyApparentHiTemp[index] = dailyForecast.data[index].apparentTemperatureMax.round
	        @dailyPrecipProb[index]		= (dailyForecast.data[index].precipProbability * 100).to_i
	        @dailyTime[index]			= convert_time(dailyForecast.data[index].time)
	        dailyMoonPhase[index]		= dailyForecast.data[index].moonPhase*100

	        #Lunar Logic
	        if dailyMoonPhase[index] >= 0 && dailyMoonPhase[index] <= 3
	        	@dailyMoonPhaseName[index]  = "🌑 &nbsp;".html_safe + "New Moon"

	        elsif dailyMoonPhase[index] > 3 && dailyMoonPhase[index] < 25
	        	@dailyMoonPhaseName[index]  = "🌒 &nbsp;".html_safe + "Waxing Crescent"	        	

	        elsif dailyMoonPhase[index] >= 25 && dailyMoonPhase[index] <= 28
	        	@dailyMoonPhaseName[index]  = "🌓 &nbsp;".html_safe + "First Quarter Moon"

	        elsif dailyMoonPhase[index] > 28 && dailyMoonPhase[index] < 50
	        	@dailyMoonPhaseName[index]  = "🌔 &nbsp;".html_safe + "Waxing Gibbous"	   	        	

	        elsif dailyMoonPhase[index] >= 50 && dailyMoonPhase[index] <= 53
	        	@dailyMoonPhaseName[index]  = "🌕 &nbsp;".html_safe + "Full Moon"

	        elsif dailyMoonPhase[index] > 53 && dailyMoonPhase[index] < 75
	        	@dailyMoonPhaseName[index]  = "🌖 &nbsp;".html_safe + "Waning Gibbous"	   

	        elsif dailyMoonPhase[index] >= 75 && dailyMoonPhase[index] <= 78
	        	@dailyMoonPhaseName[index]  = "🌗 &nbsp;".html_safe + "Last Quarter Moon"

	       elsif dailyMoonPhase[index] > 78 && dailyMoonPhase[index] < 100
	        	@dailyMoonPhaseName[index]  = "🌘 &nbsp;".html_safe + "Waning Crescent"	   

	        end


	        
	 

	        #Reformat forecast.io icon strings to be readable by skycons (upcase and underscores instead of dash)
	        dailyIcon[index]		= dailyForecast.data[index].icon.upcase
			if dailyIcon[index]    == "PARTLY-CLOUDY-DAY"
				@dailySkycon[index] = "PARTLY_CLOUDY_DAY"		
			elsif dailyIcon[index] == "PARTLY-CLOUDY-NIGHT"
				@dailySkycon[index] = "CLEAR_DAY" #if partly-cloudy-night is reported, switch to clear_day (shouldn't show night time for daily weather, 
													#but the API still reports night time cloudyness even on clear days)
			elsif dailyIcon[index] == "CLEAR-DAY"
				@dailySkycon[index] = "CLEAR_DAY"
			elsif dailyIcon[index] == "CLEAR-NIGHT"
				@dailySkycon[index] = "CLEAR_NIGHT"
			elsif dailyIcon[index] == "CLOUDY"
				@dailySkycon[index] = dailyIcon[index]
			elsif dailyIcon[index] == "RAIN"
				@dailySkycon[index] = dailyIcon[index]
			elsif dailyIcon[index] == "SLEET"
				@dailySkycon[index] = dailyIcon[index]
			elsif dailyIcon[index] == "SNOW"
				@dailySkycon[index] = dailyIcon[index]
			elsif dailyIcon[index] == "WIND"
				@dailySkycon[index] = dailyIcon[index]
			elsif dailyIcon[index] == "FOG"
				@dailySkycon[index] = dailyIcon[index]			 			 			 			 			 			
			end


	        index = index + 1
	      end

	#Hourly Weather Data

		@hourlyForecastJSON 	= forecast.hourly
	    hourlyForecast 	 	= forecast.hourly

		index = 0
		  @hourlyTime = [], hourlyIcon = [], @hourlySkycon = [], @hourlyTemp = [], @hourlyPrecip = []

		  25.times do
		    @hourlyTime[index]			= Time.at(hourlyForecast.data[index].time)
		    @hourlyTemp[index]			= hourlyForecast.data[index].temperature.to_i.to_s + "°"
		    @hourlyPrecip[index]		= ((hourlyForecast.data[index].precipProbability * 100) / 5 ).round * 5 #rounded to nearest multiple of 5 for readability		    #Reformat forecast.io icon strings to be readable by skycons (upcase and underscores instead of dash)
		    hourlyIcon[index]		= hourlyForecast.data[index].icon.upcase
			if hourlyIcon[index]    == "PARTLY-CLOUDY-DAY"
				@hourlySkycon[index] = "PARTLY_CLOUDY_DAY"		
			elsif hourlyIcon[index] == "PARTLY-CLOUDY-NIGHT"
				@hourlySkycon[index] = "PARTLY_CLOUDY_NIGHT"
			elsif hourlyIcon[index] == "CLEAR-DAY"
				@hourlySkycon[index] = "CLEAR_DAY"
			elsif hourlyIcon[index] == "CLEAR-NIGHT"
				@hourlySkycon[index] = "CLEAR_NIGHT"
			elsif hourlyIcon[index] == "CLOUDY"
				@hourlySkycon[index] = hourlyIcon[index]
			elsif hourlyIcon[index] == "RAIN"
				@hourlySkycon[index] = hourlyIcon[index]
			elsif hourlyIcon[index] == "SLEET"
				@hourlySkycon[index] = hourlyIcon[index]
			elsif hourlyIcon[index] == "SNOW"
				@hourlySkycon[index] = hourlyIcon[index]
			elsif hourlyIcon[index] == "WIND"
				@hourlySkycon[index] = hourlyIcon[index]
			elsif hourlyIcon[index] == "FOG"
				@hourlySkycon[index] = hourlyIcon[index]			 			 			 			 			 			
			end

		   
		    index = index + 1
		end




	else
		#do nothing, no cookie/location data
	end #end if/else checking for cookies[:lat_lng]
  end  #end currentLocation

end
