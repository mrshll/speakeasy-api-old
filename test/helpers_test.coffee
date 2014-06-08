helpers = require '../helpers'

should = require 'should'

describe 'helpers', ->
  describe 'randomSixDigitToken', ->
    beforeEach (done) ->
      @code = helpers.randomSixDigitToken()
      done()

    it 'should be a string', ->
      type = typeof @code
      type.should.equal "string"

    it 'should be 6 digits long', ->
      @code.length.should.equal 6

    it 'should be a number', ->
      parseInt(@code).should.not.equal NaN

    it 'should be a number within the range [0, 999999]', ->
      parseInt(@code).should.be.within 0, 999999
