expect           = require('chai').expect
_                = require('lodash')
Q                = require('q')
fs               = require('fs')
path             = require('path')
RepositoryParser = projectRequire("app/lib/repository_parser")

APIendPoint = "https://api.github.com/repos/"

describe "Repository Parse", ->
  describe "#constructor", ->
    it "creates an instance of RepositoryParser", ->
      expect(new RepositoryParser()).to.be.instanceOf RepositoryParser

    it "expect apiUrl property", ->
      api = new RepositoryParser()

      expect(api.apiUrl).eq ""

  describe "#request", ->
    it "fail for a invalid url", (done) ->
      api = new RepositoryParser("bad-url")

      api.request().fail (err) -> done()

    describe "with Real API URL", ->
      it "returns the full json of repo in github", (done) ->
        api = new RepositoryParser("#{APIendPoint}djalmaaraujo/macbook-bootstrap")

        api.request().then (repo) ->
          expect(repo.id).eq 9842244
          expect(repo.name).eq "macbook-bootstrap"
          expect(repo.full_name).eq "djalmaaraujo/macbook-bootstrap"

          done()

        .fail (err) -> done(err)

  describe "#fetch", ->
    describe "invalid", ->
      it "fails for a invalid repo", (done) ->
        api = new RepositoryParser("bad-url")
        api.request().fail (err) -> done()

    describe "valid", ->
      m = {}
      before ->
        m.klass = _.clone(RepositoryParser)
        m.klass.prototype.request = ->
          defer = Q.defer()
          fs.readFile path.join(__dirname, "..", "..", "fixtures", "app", "lib", "repository.json"), (err, file) ->
            defer.reject(err) if err
            defer.resolve(JSON.parse(file))

          defer.promise

        m.api = new m.klass("what-ever")

      it "returns a repository object based on repository model", (done) ->
        m.api.fetch("djalmaaraujo/macbook-bootstrap").then (repo) ->
          json = repo.toJSON()

          expect(json.name).eq "macbook-bootstrap"
          expect(json.ownerUsername).eq "djalmaaraujo"
          expect(json.url).eq "https://github.com/djalmaaraujo/macbook-bootstrap"
          expect(json.description).eq "My Personal SETUP"
          expect(json.totalForks).eq 4
          expect(json.totalStars).eq 13

          done()

        .fail (err) -> done(err)
