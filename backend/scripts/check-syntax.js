import { readdir } from 'node:fs/promises';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

async function listarArchivos(directorio) {
  const entradas = await readdir(directorio, { withFileTypes: true });
  const archivos = [];

  for (const entrada of entradas) {
    const ruta = join(directorio, entrada.name);
    if (entrada.isDirectory()) {
      archivos.push(...await listarArchivos(ruta));
    } else if (entrada.name.endsWith('.js')) {
      archivos.push(ruta);
    }
  }

  return archivos;
}

const directorioSrc = fileURLToPath(new URL('../src', import.meta.url));
const archivos = await listarArchivos(directorioSrc);
let fallos = 0;

for (const archivo of archivos) {
  const resultado = spawnSync(process.execPath, ['--check', archivo], {
    stdio: 'inherit',
  });
  if (resultado.status !== 0) {
    fallos += 1;
  }
}

if (fallos > 0) {
  console.error(`\n${fallos} archivo(s) con errores de sintaxis.`);
  process.exit(1);
}

console.log(`Sintaxis verificada en ${archivos.length} archivo(s).`);
