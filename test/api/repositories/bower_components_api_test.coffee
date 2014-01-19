expect             = require('chai').expect
path               = require("path")
fs                 = require("fs")
Q                  = require('q')
BowerComponentsAPI = projectRequire("api/repositories/bower_components_api")

APIendPoint = "https://bower-component-list.herokuapp.com/keyword/web-components"

describe "Bower Components API", ->
  describe "#constructor", ->
    it "creates an instance of BowerComponentsAPI", ->
      expect(new BowerComponentsAPI()).to.be.instanceOf BowerComponentsAPI

  describe "Properties", ->
    api = null

    expectProperty = (name, value = "") ->
      it "expect #{name} property", ->
        api = new BowerComponentsAPI()

        expect(api[name]).eq value

    expectProperty("apiUrl")

  describe "#request", ->
    it "fail for a invalid url", (done) ->
      api = new BowerComponentsAPI("bad-url")

      api.request().fail (err) -> done()

    describe "with Real API URL", ->
      it "returns the full json of repos in github", (done) ->
        api = new BowerComponentsAPI(APIendPoint)

        api.request().then (repos) ->
          expect(repos[0].name).eql "x-tag-view"
          expect(repos[1].name).eql "x-tag-transitions"

          done()

        .fail (err) -> done(err)
