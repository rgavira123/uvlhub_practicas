import fs from 'fs';
import { mkdirSync, existsSync, writeFileSync } from 'fs';
import { launch } from 'puppeteer';
import lighthouse from 'lighthouse';

// Crear la carpeta 'reports' si no existe
const reportsDir = './reports';
if (!existsSync(reportsDir)) {
  mkdirSync(reportsDir);
}

// Cargar configuración
const configPath = process.argv[2];
if (!fs.existsSync(configPath)) {
  console.error(`No se encontró el archivo de configuración: ${configPath}`);
  process.exit(1);
}
const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

(async () => {
  const browser = await launch({ headless: true });
  const page = await browser.newPage();

  try {
    // Login
    console.log('Iniciando sesión...');
    await page.goto(config.login.url, { timeout: 60000 });
    await page.type(config.login.usernameSelector, process.env.LOGIN_USERNAME);
    await page.type(config.login.passwordSelector, process.env.LOGIN_PASSWORD);

    console.log('Haciendo clic en el botón de login...');
    await page.waitForSelector(config.login.submitButtonSelector, { visible: true, timeout: 60000 });
    await page.click(config.login.submitButtonSelector);
    await page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 60000 });

    console.log('Login completado.');

    // Verificar cookies después del login
    const cookies = await page.cookies();
    console.log('Cookies después del login:', cookies);

    // Guardar cookies para depuración
    fs.writeFileSync('cookies.json', JSON.stringify(cookies, null, 2));
    console.log('Cookies guardadas en cookies.json');

    // Configurar cookies para las siguientes URLs
    await page.setCookie(...cookies);

    console.log('Comenzando auditorías con Lighthouse...');

    // Analizar cada URL
    for (const url of config.urls) {
      console.log(`Analizando: ${url}`);
      const report = await lighthouse(url, {
        port: new URL(browser.wsEndpoint()).port,
        output: 'html',
        onlyCategories: ['accessibility'],
      });

      const fileName = `${reportsDir}/lighthouse-report-${url.replace(/[^a-z0-9]/gi, '_')}.html`;
      writeFileSync(fileName, report.report);
      console.log(`Reporte generado: ${fileName}`);
    }
  } catch (error) {
    console.error('Error durante la auditoría:', error);
  } finally {
    await browser.close();
    console.log('Todas las auditorías completadas.');
  }
})();
