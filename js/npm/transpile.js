'use strict'

const { env: ENV } = require('node:process')
const fs = require('node:fs')
const ospath = require('node:path')

let opalCompilerPath = 'opal-compiler'
try {
    require.resolve(opalCompilerPath)
} catch {
    const npxInstallDir = ENV.PATH.split(':')[0]
    if (npxInstallDir?.endsWith('/node_modules/.bin') && npxInstallDir.startsWith(ENV.npm_config_cache + '/')) {
        opalCompilerPath = require.resolve('opal-compiler', { paths: [ospath.dirname(npxInstallDir)] })
    }
}

let builder = require(opalCompilerPath).Builder.create();
builder.appendPaths('../lib')
const transpiled = builder.build('asciidoctor-diagram.rb')
fs.mkdirSync('dist', { recursive: true })
fs.writeFileSync('dist/asciidoctor-diagram.js', transpiled.toString(), 'utf8')