`import setup from './_shared'`
`import Coalesce from 'coalesce'`

describe "rest", ->

  adapter = null
  session = null

  beforeEach ->
    setup.apply(this)
    adapter = @adapter
    session = @session

  context 'concurrent updates with simple model', ->

    beforeEach ->
      `class Post extends Coalesce.Model {}`
      Post.defineSchema
        typeKey: 'post'
        attributes:
          title: {type: 'string'}
          submitted: {type: 'boolean'}
      @App.Post = @Post = Post

      @container.register 'model:post', @Post
      
      
    it 'all flushes resolve', ->
      adapter.r['PUT:/posts/1'] = (url, type, hash) ->
        posts: {id: 1, title: hash.data.post.title, submitted: "true"}
      post = session.merge @Post.create(id: "1", title: 'twerkin', submitted: false)
      post.title = 'update1'
      f1 = session.flush()
      post.title = 'update2'
      f2 = session.flush()
      Coalesce.Promise.all([f1, f2]).then ->
        expect(adapter.h).to.eql(['PUT:/posts/1', 'PUT:/posts/1'])
        expect(post.title).to.eq('update2')


    it 'second flush waits for first to complete', ->
      calls = 0
      # make first request take longer than the second
      adapter.runLater = (callback) ->
        delay = if calls > 0
          0
        else
          10
        calls++
        Coalesce.run.later callback, delay

      adapter.r['PUT:/posts/1'] = (url, type, hash) ->
        posts: {id: 1, title: hash.data.post.title, submitted: "true"}
      post = session.merge @Post.create(id: "1", title: 'twerkin', submitted: false)
      post.title = 'update1'
      f1 = session.flush()
      post.title = 'update2'
      f2 = session.flush()
      Coalesce.Promise.all([f1, f2]).then ->
        expect(adapter.h).to.eql(['PUT:/posts/1', 'PUT:/posts/1'])
        expect(post.title).to.eq('update2')


    it 'three concurrent flushes', ->
      calls = 0
      # interleave requests
      adapter.runLater = (callback) ->
        delay = if calls % 2 == 1
          0
        else
          10
        calls++
        Coalesce.run.later callback, delay

      adapter.r['PUT:/posts/1'] = (url, type, hash) ->
        posts: {id: 1, title: hash.data.post.title, submitted: "true"}
      post = session.merge @Post.create(id: "1", title: 'twerkin', submitted: false)
      post.title = 'update1'
      f1 = session.flush()
      post.title = 'update2'
      f2 = session.flush()
      post.title = 'update3'
      f3 = session.flush()
      Coalesce.Promise.all([f1, f2, f3]).then ->
        expect(adapter.h).to.eql(['PUT:/posts/1', 'PUT:/posts/1', 'PUT:/posts/1'])
        expect(post.title).to.eq('update3')


    it 'cascades failures', ->
      calls = 0
      # interleave requests
      adapter.runLater = (callback) ->
        delay = if calls % 2 == 1
          0
        else
          10
        calls++
        Coalesce.run.later callback, delay

      adapter.r['PUT:/posts/1'] = (url, type, hash) ->
        if hash.data.post.title == 'update1'
          throw "twerkin too hard"
        rev = parseInt(hash.data.post.title.split("update")[1])+1
        posts: {id: 1, title: hash.data.post.title, submitted: "true", rev: rev}
      post = session.merge @Post.create(id: "1", title: 'twerkin', submitted: false, rev: 1)
      post.title = 'update1'
      f1 = session.flush()
      post.title = 'update2'
      f2 = session.flush()
      post.title = 'update3'
      f3 = session.flush()
      f3.then null, ->
        expect(adapter.h).to.eql(['PUT:/posts/1'])
        expect(post.title).to.eq('update3')
        shadow = session.getShadow(post)
        expect(shadow.title).to.eq('twerkin')


    it 'can retry after failure', ->
      count = 0
      adapter.r['PUT:/posts/1'] = (url, type, hash) ->
        if count++ == 0
          throw "plz twerk again"
        posts: {id: 1, title: hash.data.post.title, submitted: "true"}
      post = session.merge @Post.create(id: "1", title: 'twerkin', submitted: false)
      post.title = 'update1'
      session.flush().then null, ->
        expect(post.title).to.eq('update1')
        shadow = session.getShadow(post)
        expect(shadow.title).to.eq('twerkin')

        session.flush().then ->
          expect(post.title).to.eq('update1')
          shadow = session.getShadow(post)
          expect(shadow.title).to.eq('update1')
