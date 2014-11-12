ModalView = require 'views/kinds/ModalView'
template = require 'templates/play/modal/buy-gems-modal'

module.exports = class BuyGemsModal extends ModalView
  id: 'buy-gems-modal'
  template: template
  plain: true
  
  products: [
    { price: '$4.99', gems: 5000, id: 'gems_5' }
    { price: '$9.99', gems: 11000, id: 'gems_10' }
    { price: '$19.99', gems: 25000, id: 'gems_20' }
  ]
  
  subscriptions:
    'ipad:products': 'onIPadProducts'
    'ipad:iap-complete': 'onIAPComplete'
  
  events:
    'click button.product': 'onClickProductButton'

  constructor: (options) ->
    super(options)
    if application.isIPadApp
      @products = []
      Backbone.Mediator.publish 'buy-gems-modal:update-products' 

  getRenderData: ->
    c = super()
    c.products = @products
    return c
    
  onIPadProducts: (e) ->
    newProducts = []
    for iapProduct in e.products
      localProduct = _.find @products, { id: iapProduct.id }
      continue unless localProduct
      localProduct.price = iapProduct.price
      newProducts.push localProduct
    @products = newProducts
    @render()

  onClickProductButton: (e) ->
    productID = $(e.target).closest('button.product').val()
    console.log 'purchasing', _.find @products, { id: productID }
    
    if application.isIPadApp
      Backbone.Mediator.publish 'buy-gems-modal:purchase-initiated', { productID: productID }
      
    else
      @$el.find('.modal-body').append($('<div class="alert alert-danger">Not implemented</div>'))
      
  onIAPComplete: (e) ->
    product = _.find @products, { id: e.productID }
    purchased = me.get('purchased') ? {}
    purchased = _.clone purchased
    purchased.gems ?= 0
    purchased.gems += product.gems
    me.set('purchased', purchased)
    @hide()