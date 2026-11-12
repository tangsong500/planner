import { readFileSync, writeFileSync } from 'node:fs';

const root = new URL('../', import.meta.url);
const { version } = JSON.parse(readFileSync(new URL('package.json', root), 'utf8'));
const parts = /^(\d+)\.(\d+)\.(\d+)$/.exec(version);
if (!parts) throw new Error(`iOS requires a major.minor.patch version, received ${version}`);
const [, major, minor, patch] = parts.map(Number);
if (minor > 99 || patch > 99) throw new Error('iOS build numbers require minor and patch versions below 100');
const build = major * 10000 + minor * 100 + patch;
const project = new URL('ios/App/App.xcodeproj/project.pbxproj', root);
const original = readFileSync(project, 'utf8');
const updated = original
  .replace(/MARKETING_VERSION = [^;]+;/g, `MARKETING_VERSION = ${version};`)
  .replace(/CURRENT_PROJECT_VERSION = [^;]+;/g, `CURRENT_PROJECT_VERSION = ${build};`);
if (updated !== original) writeFileSync(project, updated);
console.log(`iOS version ${version} (${build})`);
