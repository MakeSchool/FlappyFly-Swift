import Foundation

class Obstacle: CCNode
{
    var topPipe: CCNode!
    var bottomPipe: CCNode!

    // visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
    let topPipeMinimumPositionY: CGFloat = 128
    // visibility ends at 480 and we want some meat
    let bottomPipeMaximumPositionY: CGFloat = 440
    // distance between top and bottom pipe
    let pipeDistance: CGFloat = 142

    func didLoadFromCCB() {
        topPipe.physicsBody.sensor = true
        bottomPipe.physicsBody.sensor = true
    }

    func setupRandomPosition() {
        // returns a value between 0.f and 1.f
        let randomPrecision: UInt32 = 100
        let random = CGFloat(arc4random_uniform(randomPrecision)) / CGFloat(randomPrecision)
        // calculate the end of the range of top pipe
        let range = bottomPipeMaximumPositionY - pipeDistance - topPipeMinimumPositionY
        topPipe.position = ccp(topPipe.position.x, topPipeMinimumPositionY + (random * range));
        bottomPipe.position = ccp(bottomPipe.position.x, topPipe.position.y + pipeDistance);
    }
}
