`import setup from './_shared'`
`import {postWithComments} from '../support/schemas'`

describe "RestAdapter", ->

  adapter = null
  session = null

  beforeEach ->
    setup.apply(this)
    adapter = @adapter
    session = @session
    Coalesce.__container__ = @container

    postWithComments.apply(this)
    
    @container.register 'model:comment', @Comment

  afterEach ->
    delete Coalesce.__container__

  describe '.mergePayload', ->

    data =
      post: {id: 1, title: 'ma post', comments: [2, 3]}
      comments: [{id: 2, body: 'yo'}, {id: 3, body: 'sup'}]

    it 'should merge with typeKey as context', ->
      post = adapter.mergePayload(data, 'post', session)[0]
      expect(post.title).to.eq('ma post')
      expect(post).to.eq(session.getModel(post))

    it 'should merge with no context', ->
      models = adapter.mergePayload(data, null, session)
      expect(models.size).to.eq(3)

  describe '.ajaxOptions', ->
    
    beforeEach ->
      adapter.headers = {'X-HEY': 'ohai'}
    
    it 'picks up headers from .headers', ->
      hash = adapter.ajaxOptions('/api/test', 'GET', {})
      expect(hash.beforeSend).to.not.be.null
      
      xhr =
        setRequestHeader: (key, value) -> @[key] = value
        
      hash.beforeSend(xhr)
      expect(xhr['X-HEY']).to.eq('ohai')
      
