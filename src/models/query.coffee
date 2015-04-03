class Query extends Backbone.Model
    defaults:
        q: null
        filters: {}
        page: 0

    # these seem backwards because results are
    # sorted by time DESC
    prev: ->
        @.set 'page', @.get('page') + 1

    next: ->
        @.set 'page', @.get('page') - 1


