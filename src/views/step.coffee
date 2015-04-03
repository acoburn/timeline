class AbstractStep extends Backbone.View

    initialize: -> App.results.on 'change', @render

    render: =>
        @$el.html if @show_step() then $(@tpl).html() else @$el.html "<div></div>"

    events:
        'click': ->
            @step()
            App.results.fetch()

class Next extends AbstractStep
    
    show_step: -> App.results.get('start') > 0
        
    step: -> App.query.next() if App.results.get('start') > 0

    tpl: "#next-tpl"

class Prev extends AbstractStep

    show_step: -> App.results.offset() < App.results.get 'count'
        
    step: -> App.query.prev() if App.results.offset() < App.results.get 'count'

    tpl: "#prev-tpl"
