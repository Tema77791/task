# frozen_string_literal: true
file_name = ''
When(/^захожу на страницу "(.+?)"$/) do |url|
  visit url
  $logger.info("Страница #{url} открыта")
  sleep 1
end
When(/^Нажимаю на кнопку с текстом (.+?)$/) do |text|
 find(".//a[text()=#{text}]").click
 $logger.info("Кнопка #{text} нажата")
  sleep 1
end
When(/^Скачиваю первый файл из раздела (.+?)$/) do |text|

   last_version = find(".//strong[text()=#{text}]/following-sibling::ul[last()]/li[1]/a[1]")
   file_name = last_version[:href][last_version[:href].rindex('/')+1..]
   last_version.click
   $logger.info("Загрузка #{file_name} началась")
   sleep 15
end
When(/^Проверяю файл в нужной директории по имени файла установщика$/) do
  if !File.exists?("./features/tmp/#{file_name}")
    fail ("Файл #{file_name} не найден!")
  end
  $logger.info("Файл #{file_name} успешно загружен")
  sleep 1
end
When(/^ввожу в поисковой строке текст "([^"]*)"$/) do |text|
  query = find("//input[@name='q']")
  query.set(text)
  query.native.send_keys(:enter)
  $logger.info('Поисковый запрос отправлен')
  sleep 1
end

When(/^кликаю по строке выдачи с адресом (.+?)$/) do |url|
  link_first = find("//a[@href='/']/h3")
  link_first.click
  $logger.info("Переход на страницу #{url} осуществлен")
  sleep 1
end

When(/^я должен увидеть текст на странице "([^"]*)"$/) do |text_page|
  sleep 1
  expect(page).to have_text text_page
end
