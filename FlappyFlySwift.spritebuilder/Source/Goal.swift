
import Foundation

class Goal : CCNode
{
    func didLoadFromCCB() {
        physicsBody.sensor = true;
    }
}
