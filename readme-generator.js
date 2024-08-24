console.log('Generating README.md');

let fs = require('fs');
let path = require('path');

const isDirectory = (source) => fs.lstatSync(source).isDirectory();
const getDirectories = (source) =>
    fs
        .readdirSync(source)
        .map((name) => path.join(source, name))
        .filter(isDirectory);

// Change these
let rootDir = 'godot-practice';
let heading = 'godot-practice';

let readmeFile = __dirname + '/README.md';

let dirs = getDirectories('./projects');
let links = [];
for (let i = 0; i < dirs.length; i++) {
    const subDir = dirs[i].replace('projects/', '');
    links.push(`https://rohitkrishna094.github.io/${rootDir}/projects/${subDir}/`);
}

let content = `# [${heading}](https://rohitkrishna094.github.io/${rootDir}/)\n\n`;
content += 'These are some games in godot engine for practicing and learning gamedev. Click the links below for their demonstration\n\n';
for (let i = 0; i < links.length; i++) {
    const subDir = dirs[i].replace('projects/', '');
    content += `* [${subDir}](${links[i]})\n`;
}

fs.writeFileSync(readmeFile, content);