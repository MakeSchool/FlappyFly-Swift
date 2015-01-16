import Foundation

class Obstacle : CCNode
{
    var _topPipe : CCNode!
    var _bottomPipe : CCNode!

    // visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
    let _topPipeMinimumPositionY : CGFloat = 128
    // visibility ends at 480 and we want some meat
    let _bottomPipeMaximumPositionY : CGFloat = 440
    // distance between top and bottom pipe
    let _pipeDistance : CGFloat = 142

    func didLoadFromCCB() {
        _topPipe.physicsBody.sensor = true
        _bottomPipe.physicsBody.sensor = true
    }

    func setupRandomPosition() {
        // returns a value between 0.f and 1.f
        let _randomPrecision : UInt32 = 100
        let random = CGFloat(arc4random_uniform(_randomPrecision)) / CGFloat(_randomPrecision)
        // calculate the end of the range of top pipe
        let range = _bottomPipeMaximumPositionY - _pipeDistance - _topPipeMinimumPositionY
        _topPipe.position = ccp(_topPipe.position.x, _topPipeMinimumPositionY + (random * range));
        _bottomPipe.position = ccp(_bottomPipe.position.x, _topPipe.position.y + _pipeDistance);
    }
}
