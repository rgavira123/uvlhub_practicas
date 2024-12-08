const fs = require('fs');
const lighthouse = require('lighthouse');
const puppeteer = require('puppeteer');
const { writeFileSync } = require('fs');

// Cargar configuración
const configPath = process.argv[2];
const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

(async () => {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  // Login
  console.log('Iniciando sesión...');
  await page.goto(config.login.url);
  await page.type(config.login.usernameSelector, process.env.LOGIN_USERNAME);
  await page.type(config.login.passwordSelector, process.env.LOGIN_PASSWORD);
  await page.click(config.login.submitButtonSelector);
  await page.waitForNavigation();

  console.log('Login exitoso. Comenzando auditorías...');

  // Analizar cada URL
  for (const url of config.urls) {
    console.log(`Analizando: ${url}`);
    const report = await lighthouse(url, {
      port: (new URL(browser.wsEndpoint())).port,
      output: 'html',
      onlyCategories: ['accessibility'],
    });

    const fileName = `lighthouse-report-${url.replace(/[^a-z0-9]/gi, '_')}.html`;
    writeFileSync(fileName, report.report);
    console.log(`Informe guardado: ${fileName}`);
  }

  await browser.close();
  console.log('Todas las auditorías completadas.');
})().catch(err => {
  console.error(err);
  process.exit(1);
});
