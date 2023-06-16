'use strict'

const Extensions = require('./extensions')

module.exports.register = (registry) => Extensions.$register_all(registry)