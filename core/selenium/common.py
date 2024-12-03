import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager


def initialize_driver():
    # Initializes the browser options
    options = webdriver.ChromeOptions()

    # Initialise the browser using WebDriver Manager
    # driver_path = ChromeDriverManager().install()
    # chromediver_binary = os.path.join(os.path.dirname(driver_path), 'chromedriver')
    # service = Service(chromediver_binary)
    
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.binary_location = ('/home/ramon/Descargas/chrome-linux64 (1)/chrome-linux64/chrome')

    os.getenv('SELENIUM_BINARY_LOCATION', '')

        # Iniciar el driver de Chromium usando webdriver-manager
    service = Service("/usr/bin/chromedriver")
    driver = webdriver.Chrome(service=service, options=options)
        
    # driver = webdriver.Chrome(service=service, options=options)
    return driver


def close_driver(driver):
    driver.quit()
