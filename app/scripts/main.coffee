'use strict'


angular.module('Polygons')


.directive('maxCanvas', ($window) ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->
      # console.log element[0]
      # elem = element.children()[0]
      # height = $window.innerHeight
      # element.style.height = height+'px'
      return
  }

)


.controller('MainCtrl', ($scope, $timeout, $ionicPopup, storage, randomPolygonView) ->

  # localStorage.clear()
  
  # Init data
  storage.bind $scope, 'recode', {defaultValue:{
    bestscore: 0
  }}

  # if not $scope.recode?
  #   $scope.recode = {
  #     bestscore: 0
  #   }

  $scope.now_score = 0

  $scope.viewing = 'main'
  $scope.covering = true

  $scope.onclickStart = ->
    $scope.now_score = 0
    _showQuestionView()

  $scope.onclickNext = ->
    _showQuestionView()

  _showQuestionView = ->
    randomPolygonView.setPointsNumRangeByScore $scope.now_score

    $scope.viewing = 'question'
    $scope.questing = 'quest'
    $scope.covering = true
    _showPolygon()
    $timeout( ->
      $scope.covering = false
      $timeout( ->
        $scope.covering = true
        $timeout( ->
          $scope.questing = 'answer'
        , 1000)
      , 400)
    , 1000)


  _showPolygon = ->
    $scope.inputNumber = 0
    $scope.pointsNum = randomPolygonView.showPolygon()


  $scope.onclickOK = ->
    $scope.questing = false
    $scope.incorrect = true
    $scope.covering = false
    
    # If correct, show question view
    # If incorrect, show incorrect view
    if $scope.inputNumber is $scope.pointsNum
      $scope.now_score++
      console.log $scope.now_score
      $scope.questing = 'correct'
      randomPolygonView.showPolygonFace true
    else
      if $scope.now_score > $scope.recode.bestscore
        $scope.recode.bestscore = $scope.now_score
      $scope.questing = 'incorrect'
      randomPolygonView.showPolygonFace false

  $scope.onclickClear = ->
    $scope.inputNumber = 0

  $scope.onclickNumber = (number) ->
    return if String($scope.inputNumber).length >= 2
    inputString = ''
    if $scope.inputNumber is 0
      if number is 0 or
         number is 1 or
         number is 2
        return
      $scope.inputNumber = ''
    $scope.inputNumber = Number(String($scope.inputNumber) + String(number))

  $scope.onclickBack = ->
    $scope.viewing = 'main'

  $scope.onclickInfo = ->
    $ionicPopup.alert {
      title: 'Legal Notices'
      template: 'text'
      okText: 'Close'
    }
)


.factory('randomPolygonView', (polygonView, randomPolygon) ->
  polygonView.initPolygon 'polygon'
  return {
    setPointsNumRangeByScore: (num) ->
      minNum = 0
      maxNum = 0
      if num < 2
        minNum = 3
        maxNum = 6
      else if num < 10
        minNum = 3
        maxNum = 8
      else if num < 20
        minNum = 5
        maxNum = 10
      else if num < 30
        minNum = 5
        maxNum = 15
      else
        minNum = 5
        maxNum = 20
      randomPolygon.setPointsNumRange minNum, maxNum

    showPolygon: ->
      polygonView.clearView()
      return polygonView.showPolygon(
        randomPolygon.getPoints()
        randomPolygon.getColor()
      )
    showPolygonFace: (type) ->
      polygonView.showPolygonFace(
        randomPolygon.getFacePoints()
        type
      )
      return

  }
)


.service('polygonView', ->
  _canvas = {}
  _context = {}

  ###*
   * Initialize canvas
   * @param  {[type]} canvas [description]
   * @return {[type]}        [description]
  ###
  @initPolygon = (canvas) ->
    _canvas = document.getElementById canvas
    return false if not _canvas? and not _canvas.getContext?
    _context = _canvas.getContext '2d'

    _context.strokeStyle = 'rgba(0,0,0,0)'
    @

  ###*
   * Clear view
   * @return {[type]} [description]
  ###
  @clearView = ->
    _context.clearRect 0, 0, 300, 400
    @

  ###*
   * Show polygon
   * @param  {object} points     [description]
   * @param  {string} color      [description]
   * @return {number}            Number of points
  ###
  @showPolygon = (points, color) ->
    _context.strokeStyle = '#ffffff'
    _context.beginPath()
    angular.forEach(points, (point, i) ->
      if i isnt 0
        _context.lineTo point.x, point.y
      else
        _context.moveTo point.x, point.y
    )
    _context.stroke()
    _context.closePath()

    _context.fillStyle = color
    _context.fill()

    return points.length

  ###*
   * Show face of polygonFace
   * @param  {object}  points     [description]
   * @param  {boolean} type       Face type
  ###
  @showPolygonFace = (points, type) ->
    _context.fillStyle = '#000000'
    _context.beginPath()
    _context.arc points.eyePoint1.x, points.eyePoint1.y, 2, 0, 2*Math.PI, false
    _context.fill()
    
    _context.beginPath()
    _context.arc points.eyePoint2.x, points.eyePoint2.y, 2, 0, 2*Math.PI, false
    _context.fill()

    _context.strokeStyle = '#000000'
    _context.beginPath()
    if type is true
      _context.arc points.mouthPoint.x, points.mouthPoint.y, 10, Math.PI/3, Math.PI/3*2, false
    else
      _context.arc points.mouthPoint.x, points.mouthPoint.y+20, 10, -Math.PI/3, -Math.PI/3*2, true  
    _context.stroke()

    return

  return
)


.factory('randomPolygon', ->
  _minNum = 4
  _maxNum = 9
  _maxLen = 30
  _minLen = 60
  _maxX = 300
  _minX = 0
  _maxY = 400
  _minY = 0
  _angleMargin = 10
  _colors = [
    '#4a87ee'
    '#43cee6'
    '#f0b840'
    '#ef4e3a'
    '#d39211'
    '#8a6de9'
  ]

  _randomPoints = []

  _getNumber = ->
    return _getRamdomByRange _minNum, _maxNum

  _getLength = ->
    return _getRamdomByRange _minLen, _maxLen

  _getRamdomByRange = (min, max) ->
    return Math.floor(Math.random() * (max - min - 1)) + min

  _deg2rad = (deg) ->
    return deg / 180 * Math.PI

  _polar2rect = (r, rad) ->
    return {
      x: r * Math.cos(rad)
      y: r * Math.sin(rad)
    }

  _adjustIntoArea = (points) ->
    pointXs = []
    pointYs = []

    angular.forEach(points, (point, i) ->
      pointXs.push point.x
      pointYs.push point.y
    )

    maxX = Math.max.apply(null, pointXs)
    minX = Math.min.apply(null, pointXs)
    maxY = Math.max.apply(null, pointYs)
    minY = Math.min.apply(null, pointYs)

    if maxX > _maxX
      angular.forEach(points, (point, i) ->
        point.x -= (maxX - _maxX)
      )
    else if minX < _minX
      angular.forEach(points, (point, i) ->
        point.x -= (minX - _minX)
      )
    if maxY > _maxY
      angular.forEach(points, (point, i) ->
        point.y -= (maxY - _maxY)
      )
    else if minY < _minY
      angular.forEach(points, (point, i) ->
        point.y -= (minY - _minY)
      )
    return

  _getStartPoint = ->
    return {
      x: _getRamdomByRange(50, 250)
      y: _getRamdomByRange(50, 350)
    }

  return {
    setPointsNumRange: (min, max) ->
      _minNum = min
      _maxNum = max

    getPoints: ->
      num = _getNumber()
      baseAngle = _deg2rad(180 * (num - 2) / num)
      beforeAngle = _deg2rad(_getRamdomByRange(0, 60))
      
      points = [
        {x:0,y:0}
        _polar2rect _getLength(), beforeAngle
      ]

      for i in [0..(num-3)]
        angleMargin = _deg2rad(_getRamdomByRange(-_angleMargin, _angleMargin))
        angle = beforeAngle + (_deg2rad(180) - baseAngle) + angleMargin
        point = _polar2rect _getLength(), angle
        beforeAngle = angle
        point.x += points[i+1].x
        point.y += points[i+1].y
        points.push point

      startPoint = _getStartPoint()
      angular.forEach(points, (point, i) ->
        point.x += startPoint.x
        point.y += startPoint.y
      )

      _adjustIntoArea points

      _randomPoints = points
      return _randomPoints

    getColor: ->
      return _colors[_getRamdomByRange(0, _colors.length-1)]


    getFacePoints: ->
      eyePoint1 = {}
      eyePoint2 = {}
      mouthPoint = {}
      eyePoint1.x = _randomPoints[0].x
      eyePoint1.y = _randomPoints[0].y + 10
      eyePoint2.x = _randomPoints[0].x + 10
      eyePoint2.y = _randomPoints[0].y + 10
      mouthPoint.x = eyePoint1.x + 5
      mouthPoint.y = eyePoint1.y
      
      return {
        eyePoint1: eyePoint1
        eyePoint2: eyePoint2
        mouthPoint: mouthPoint
      }
  }
)