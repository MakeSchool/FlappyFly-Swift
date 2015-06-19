import Foundation

class MainScene : CCNode, CCPhysicsCollisionDelegate
{
    var scrollSpeed: CGFloat = 80
    
    weak var hero: CCSprite!
    weak var gamePhysicsNode: CCPhysicsNode!
    
    weak var ground1: CCSprite!
    weak var ground2: CCSprite!
    var grounds: [CCSprite] = []  // initializes an empty array

    var sinceTouch: CCTime = 0
    
    var obstacles: [CCNode] = []
    let firstObstaclePosition: CGFloat = 280
    let distanceBetweenObstacles: CGFloat = 160

    weak var obstaclesLayer: CCNode!

    weak var restartButton: CCButton!
    var isGameOver = false

    var points: NSInteger = 0
    weak var scoreLabel: CCLabelTTF!
    
    func didLoadFromCCB() {
        gamePhysicsNode.collisionDelegate = self
        
        self.userInteractionEnabled = true
        grounds.append(ground1)
        grounds.append(ground2)

        // spawn the first obstacles
        spawnNewObstacle()
        spawnNewObstacle()
        spawnNewObstacle()
    }
    
    override func update(delta: CCTime) {
        hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y)
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
        
        // clamp physics node position to the next nearest pixel value to avoid black line artifacts
        var scale = CCDirector.sharedDirector().contentScaleFactor
        gamePhysicsNode.position = ccp(round(gamePhysicsNode.position.x * scale) / scale, round(gamePhysicsNode.position.y * scale) / scale)
        
        // loop the ground whenever a ground image was moved entirely outside the screen
        for ground in grounds {
            // get the world position of the ground
            let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(ground.position)
            // get the screen position of the ground
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
            // if the left corner is one complete width off the screen, move it to the right
            if groundScreenPosition.x <= (-ground.contentSize.width) {
                ground.position = ccp(ground.position.x + ground.contentSize.width * 2, ground.position.y)
            }
        }

        // clamp velocity
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))

        // clamp angular velocity
        sinceTouch += delta
        hero.rotation = clampf(hero.rotation, -30, 90)
        if (hero.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1)
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        // rotate downwards if enough time passed since last touch
        if (sinceTouch > 0.5) {
            let impulse = -20000.0 * delta
            hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
        
        // checking for removable obstacles
        for obstacle in obstacles.reverse() {
            let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
            let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
            
            // obstacle moved past left side of screen?
            if obstacleScreenPosition.x < (-obstacle.contentSize.width) {
                obstacle.removeFromParent()
                obstacles.removeAtIndex(find(obstacles, obstacle)!)
                
                // for each removed obstacle, add a new one
                spawnNewObstacle()
            }
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (isGameOver == false) {
            // move up and rotate
            hero.physicsBody.applyImpulse(ccp(0, 400))
            hero.physicsBody.applyAngularImpulse(10000)
            sinceTouch = 0
        }
    }

    func spawnNewObstacle() {
        var prevObstaclePos = firstObstaclePosition
        if obstacles.count > 0 {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // create and add a new obstacle
        let obstacle = CCBReader.load("Obstacle") as! Obstacle
        obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
        obstacle.setupRandomPosition()
        obstaclesLayer.addChild(obstacle)
        obstacles.append(obstacle)
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero nodeA: CCNode!, goal: CCNode!) -> Bool {
        goal.removeFromParent()
        points++
        scoreLabel.string = String(points)
        return true
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool {
        gameOver()
        return true
    }
    
    func restart() {
        var scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().replaceScene(scene)
    }
    
    func gameOver() {
        if (isGameOver == false) {
            isGameOver = true
            restartButton.visible = true
            scrollSpeed = 0
            hero.rotation = 90
            hero.physicsBody.allowsRotation = false
            
            // just in case
            hero.stopAllActions()
            
            var move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
            var moveBack = CCActionEaseBounceOut(action: move.reverse())
            var shakeSequence = CCActionSequence(array: [move, moveBack])
            runAction(shakeSequence)
        }
    }
}
