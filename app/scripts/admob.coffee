'use strict'

angular.module('Polygons')


.directive 'admob', ($ionicPlatform) ->
  return {
    restrict: 'A'
    controller: ['$scope', ($scope) ->
      $ionicPlatform.ready ->
        return if not admob?
        
        admob.initAdmob(
          'ca-app-pub-5059946936929341/7104002516', # bannar ID
          '') # interstitial ID
        admob.showBanner admob.BannerSize.BANNER, admob.Position.BOTTOM_CENTER
        return
    ]
  }