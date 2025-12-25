import fs from "fs";
import path from "path";

const publicDir = path.join(process.cwd(), "public");
const distDir = path.join(process.cwd(), "dist");

fs.rmSync(distDir, { recursive: true, force: true });
fs.mkdirSync(distDir, { recursive: true });

const srcFile = path.join(publicDir, "index.html");
const destFile = path.join(distDir, "index.html");

if (!fs.existsSync(srcFile)) {
  console.error("Missing public/index.html");
  process.exit(1);
}

fs.copyFileSync(srcFile, destFile);
console.log("build: static bundle created at dist/index.html");
