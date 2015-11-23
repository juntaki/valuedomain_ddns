# -*- coding: utf-8 -*-
require "selenium-webdriver"
require 'headless'
require 'yaml'

setting = YAML.load_file('valuedomain_config.yml')

headless = Headless.new
headless.start

driver = Selenium::WebDriver.for :firefox

driver.get("http://dyn.value-domain.com/cgi-bin/dyn.fcg?ip")
ip = driver.find_element(:xpath, "//body").text
puts ip

base_url = "https://www.value-domain.com/"

driver.get(base_url + "/login.php")
driver.find_element(:name, "username").clear
driver.find_element(:name, "username").send_keys setting['user']
driver.find_element(:name, "password").clear
driver.find_element(:name, "password").send_keys setting['password']
driver.find_element(:name, "Submit").click

driver.get(base_url + "/moddns.php?action=moddns2&domainname=#{setting['domain']}")
1.upto(9) do |i|
  value = driver.find_element(:id, "idHostName#{i}").attribute("value")
  next unless value == setting['subdomain']

  curip = driver.find_element(:id, "idAddress#{i}").attribute("value")
  puts "SAME"  if curip == ip
  break if curip == ip

  puts "SET"
  driver.find_element(:id, "idAddress#{i}").clear
  driver.find_element(:id, "idAddress#{i}").send_keys ip
  driver.find_element(:name, "Submit").click
  break
end
puts "OK"
headless.destroy
