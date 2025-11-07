local Translations = {
  -- Notifications
  you_paid = 'You paid $%{value}',
  passed_test = 'You passed the test',
  failed_test = 'You failed the test',
  driving_test_complete = 'Driving test complete',
  driving_too_fast = 'You are driving too fast! Speed limit: %{value} km/h!',
  errors = 'Errors: %{value}/%{value2}',
  you_damaged_veh = 'You damaged your vehicle',
  not_enough_money = 'You don\'t have enough money',
  no_code = 'You haven\'t passed your theory test',
  goto_cityhall = 'Go to City Hall to collect your license',
  license_updated = 'Your license has been updated',

  -- Mission
  go_next_point = 'Go to the next checkpoint!',
  in_town_speed = 'Entering the city, watch your speed! Speed limit: ~y~%{value}~s~ km/h',
  next_point_speed = 'Head to the next checkpoint! Speed limit: ~y~%{value}~s~ km/h',
  stop_for_ped = 'Make a quick ~r~stop~s~ for the ~y~pedestrian~s~ crossing',
  good_lets_cont = '~g~Good!~s~ Let’s continue!',
  stop_look_left = 'Make a quick ~r~stop~s~ and look to your ~y~left~s~. Speed limit: ~y~%{value}~s~ km/h',
  good_turn_right = '~g~Good~s~! Turn ~y~right~s~ and stay in your lane',
  watch_traffic_lightson = 'Watch the traffic and ~y~turn on your lights~s~!',
  stop_for_passing = 'Stop to let vehicles pass!',
  hway_time = 'Time to get on the highway! Speed limit: ~y~%{value}~s~ km/h',
  gratz_stay_alert = 'Good job, stay alert!',

  -- Menu
  theory_test = 'Theory Test',
  flight_test_plane = 'Flight Test [Plane]',
  flight_test_heli = 'Flight Test [Helicopter]',
  school_item = '$%{value}',
  driving_school = 'Flight School',

  -- Misc
  driving_school_blip = 'Flight School',
  drive_school_e = '[~g~E~w~] Flight School',
  -- press_open_menu = 'Press ~INPUT_CONTEXT~ to open the menu',
}


--if not Lang then            --This test is only needed in locale en, please comment it on other languages

local templocale = Locale:new({
  phrases = Translations,
  warnOnMissing = true,
  locale = "fr"
}) 
if templocale then
  Lang = templocale
end

--end                         --Comment this line also