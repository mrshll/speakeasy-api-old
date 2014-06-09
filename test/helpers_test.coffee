helpers = require '../helpers'

should = require 'should'
moment = require 'moment'

describe 'helpers', ->
  describe '#calculateFutureDelivery', ->
    it 'should return a date in the future', (done) ->
      now = moment()
      future_date = helpers.calculateFutureDelivery 'days', 6
      future_date.isAfter(now).should.equal true
      done()

  describe '#randomSixDigitToken', ->
    beforeEach (done) ->
      @code = helpers.randomSixDigitToken()
      done()

    it 'should be a string', ->
      type = typeof @code
      type.should.equal "string"

    it 'should be 6 digits long', ->
      @code.length.should.equal 6

    it 'should parse as an integer', ->
      parseInt(@code).should.not.equal NaN

    it 'should be within the range [0, 999999]', ->
      parseInt(@code).should.be.within 0, 999999
