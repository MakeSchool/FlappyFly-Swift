import Foundation

class MainScene : CCNode, CCPhysicsCollisionDelegate
{
    var _scrollSpeed: CGFloat = 80
    
    var _hero: CCSprite!
    var _physicsNode: CCPhysicsNode!
    
    var _ground1: CCSprite!
    var _ground2: CCSprite!
    var _grounds: [CCSprite] = []  // initializes an empty array

    var _sinceTouch: CCTime = 0
    
    var _obstacles: [CCNode] = []
    let _firstObstaclePosition: CGFloat = 280
    let _distanceBetweenObstacles: CGFloat = 160

    var _obstaclesLayer: CCNode!

    var _restartButton: CCButton!
    var _gameOver = false

    var _points: NSInteger = 0
    var _scoreLabel: CCLabelTTF!
    
    func didLoadFromCCB() {
        _physicsNode.collisionDelegate = self
        
        self.userInteractionEnabled = true
        _grounds.append(_ground1)
        _grounds.append(_ground2)

        // spawn the first obstacles
        self.spawnNewObstacle()
        self.spawnNewObstacle()
        self.spawnNewObstacle()
    }
    
    override func update(delta: CCTime) {
        _hero.position = ccp(_hero.position.x + _scrollSpeed * CGFloat(delta), _hero.position.y)
        _physicsNode.position = ccp(_physicsNode.position.x - _scrollSpeed * CGFloat(delta), _physicsNode.position.y)
        
        // clamp physics node position to the next nearest pixel value to avoid black line artifacts
        var scale = CCDirector.sharedDirector().contentScaleFactor
        _physicsNode.position = ccp(round(_physicsNode.position.x * scale) / scale, round(_physicsNode.position.y * scale) / scale)
        
        // loop the ground whenever a ground image was moved entirely outside the screen
        for ground in _grounds {
            // get the world position of the ground
            let groundWorldPosition = _physicsNode.convertToWorldSpace(ground.position)
            // get the screen position of the ground
            let groundScreenPosition = self.convertToNodeSpace(groundWorldPosition)
            // if the left corner is one complete width off the screen, move it to the right
            if groundScreenPosition.x <= (-ground.contentSize.width) {
                ground.position = ccp(ground.position.x + ground.contentSize.width * 2, ground.position.y)
            }
        }

        // clamp velocity
        let velocityY = clampf(Float(_hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        _hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))

        // clamp angular velocity
        _sinceTouch += delta
        _hero.rotation = clampf(_hero.rotation, -30, 90)
        if (_hero.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(_hero.physicsBody.angularVelocity), -2, 1)
            _hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        // rotate downwards if enough time passed since last touch
        if (_sinceTouch > 0.5) {
            let impulse = -20000.0 * delta
            _hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
        
        // checking for removable obstacles
        for obstacle in _obstacles.reverse() {
            let obstacleWorldPosition = _physicsNode.convertToWorldSpace(obstacle.position)
            let obstacleScreenPosition = self.convertToNodeSpace(obstacleWorldPosition)
            
            // obstacle moved past left side of screen?
            if obstacleScreenPosition.x < (-obstacle.contentSize.width) {
                obstacle.removeFromParent()
                _obstacles.removeAtIndex(find(_obstacles, obstacle)!)
                
                // for each removed obstacle, add a new one
                self.spawnNewObstacle()
            }
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (_gameOver == false) {
            // move up and rotate
            _hero.physicsBody.applyImpulse(ccp(0, 400))
            _hero.physicsBody.applyAngularImpulse(10000)
            _sinceTouch = 0
        }
    }

    func spawnNewObstacle() {
        var prevObstaclePos = _firstObstaclePosition
        if _obstacles.count > 0 {
            prevObstaclePos = _obstacles.last!.position.x
        }
        
        // create and add a new obstacle
        let obstacle = CCBReader.load("Obstacle") as Obstacle
        obstacle.position = ccp(prevObstaclePos + _distanceBetweenObstacles, 0)
        obstacle.setupRandomPosition()
        _obstaclesLayer.addChild(obstacle)
        _obstacles.append(obstacle)
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero nodeA: CCNode!, goal: CCNode!) -> Bool {
        goal.removeFromParent()
        _points++
        _scoreLabel.string = String(_points)
        return true
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool {
        self.gameOver()
        return true
    }
    
    func restart() {
        var scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().replaceScene(scene)
    }
    
    func gameOver() {
        if (_gameOver == false) {
            _gameOver = true
            _restartButton.visible = true
            _scrollSpeed = 0
            _hero.rotation = 90
            _hero.physicsBody.allowsRotation = false
            
            // just in case
            _hero.stopAllActions()
            
            var move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
            var moveBack = CCActionEaseBounceOut(action: move.reverse())
            var shakeSequence = CCActionSequence(array: [move, moveBack])
            self.runAction(shakeSequence)
        }
    }
}
