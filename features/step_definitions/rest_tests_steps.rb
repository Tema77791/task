# frozen_string_literal: true

When(/^получаю информацию о пользователях$/) do
  users_full_information = $rest_wrap.get('/users')

  $logger.info('Информация о пользователях получена')
  @scenario_data.users_full_info = users_full_information
end

When(/^проверяю (наличие|отсутствие) логина (\w+\.\w+) в списке пользователей$/) do |presence, login|
  search_login_in_list = true
  presence == 'отсутствие' ? search_login_in_list = !search_login_in_list : search_login_in_list

  logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }
  login_presents = logins_from_site.include?(login)

  if login_presents
    message = "Логин #{login} присутствует в списке пользователей"
    search_login_in_list ? $logger.info(message) : raise(message)
  else
    message = "Логин #{login} отсутствует в списке пользователей"
    search_login_in_list ? raise(message) : $logger.info(message)
  end
end

When(/^добавляю пользователя c логином (\w+\.\w+) именем (\w+) фамилией (\w+) паролем ([\d\w@!#]+)$/) do
|login, name, surname, password|

  response = $rest_wrap.post('/users', login: login,
                                       name: name,
                                       surname: surname,
                                       password: password,
                                       active: 1)
  $logger.info(response.inspect)
end

When(/^добавляю пользователя с параметрами:$/) do |data_table|
  user_data = data_table.raw

  login = user_data[0][1]
  name = user_data[1][1]
  surname = user_data[2][1]
  password = user_data[3][1]

  step "добавляю пользователя c логином #{login} именем #{name} фамилией #{surname} паролем #{password}"
end

When(/^удаляю пользователя с логином (\w+\.\w+)$/) do |login|
  user_id = find_user_id(users_information: @scenario_data
                                    .users_full_info,
               user_login: login)
  if user_id.nil?
    raise ("пользователь с #{login} не найден")
  end
  response = $rest_wrap.delete("/users/#{user_id}")
  if response['status'] != 200
    raise ("Пользователь с #{user_id} не удален")
  end
  $logger.info(response.inspect)
end

When(/^нахожу пользователя с логином (\w+\.\w+)$/) do |login|
  step %(получаю информацию о пользователях)
  if @scenario_data.users_id[login].nil?
    @scenario_data.users_id[login] = find_user_id(users_information: @scenario_data
                                                                         .users_full_info,
                                                  user_login: login)
  end

  $logger.info("Найден пользователь #{login} с id:#{@scenario_data.users_id[login]}")
end

When(/^изменяю данные пользователя с логином (\w+\.\w+) на: имя (\w+) фамилия (\w+) активность (\d+)$/) do
|login, name, surname, active|
  user_id = find_user_id(users_information: @scenario_data
                                              .users_full_info,
                         user_login: login)
  if user_id.nil?
    raise ("пользователь с #{login} не найден")
  end
  response = $rest_wrap.put("/users/#{user_id}",
                             name: name,
                             surname: surname,
                            active: active)
  $logger.info(response.inspect)
end
When(/^проверяю что у пользователя с логином (\w+\.\w+) следующие: имя (\w+) фамилия (\w+) активность (\d+)$/) do
|login, name, surname, active|
  user_info = nil
  @scenario_data.users_full_info.each do |user|
    next unless user['login'] == login
    user_info = user
  end

  if user_info['name'] != name
    raise ("имя пользователя должно быть #{name}, но #{user_info['name']}")
  end
  if user_info['surname'] != surname
    raise ("фамилия пользователя должно быть #{surname}, но #{user_info['surname']}")
  end
  if user_info['active'] != active.to_i
    raise ("статус пользователя должен быть #{active}, но #{user_info['active']}")
  end
end