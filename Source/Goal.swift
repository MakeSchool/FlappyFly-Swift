
import Foundation

class Goal: CCNode
{
    func didLoadFromCCB() {
        self.physicsBody.sensor = true;
    }
}
