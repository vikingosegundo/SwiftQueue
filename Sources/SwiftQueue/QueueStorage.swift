@usableFromInline
internal final class QueueStorage<T> {
    
    @usableFromInline
    internal class Box {
        
        @usableFromInline
        var next: Box?
        
        @usableFromInline
        var element: T
        
        @usableFromInline
        init?(_ element: T?) {
            guard let theElement = element else { return nil }
            
            self.element = theElement
        }
    }
    
    @usableFromInline
    required internal init() {}
    
    @usableFromInline
    internal var start: Box? = nil
    
    @usableFromInline
    internal var end: Box? = nil
    
    @usableFromInline
    internal var count: Int = 0
}

extension QueueStorage {
    
    @inlinable
    internal func checkIndex(_ index: Int) {
        guard index >= 0 && index < count else {
            fatalError("Index out of range")
        }
    }
    
    @inlinable
    internal func getBoxForUncheckedIndex(_ index: Int) -> Box {
        var currentBox = start!
        for _ in 0 ..< index {
            currentBox = currentBox.next!
        }
        return currentBox
    }
    
    @inlinable
    internal func getElementAtUncheckedIndex(_ index: Int) -> T {
        let box = getBoxForUncheckedIndex(index)
        return box.element
    }
    
    @inlinable
    internal func setElementAtUncheckedIndex(_ index: Int, to newValue: T) {
        let box = getBoxForUncheckedIndex(index)
        box.element = newValue
    }
    
    @inlinable
    func index(after i: Int) -> Int {
        return i + 1
    }
}

extension QueueStorage {
    
    @inlinable
    func append(_ newElement: __owned T) {
        
        count += 1
        
        let newBox = Box(newElement)
        
        guard let oldEnd = end else {
            start = newBox
            end = newBox
            return
        }
        
        oldEnd.next = newBox
        end = newBox
    }
    
    @inlinable
    func popFirst() -> T? {
        guard let oldStart = start else {
            return nil
        }
        count -= 1
        start = oldStart.next
        if start == nil { end = nil }
        return oldStart.element
    }
    
    @inlinable
    func removeFirst() -> T {
        guard let oldStart = start else {
            fatalError("removeFirst() called on empty collection")
        }
        count -= 1
        start = oldStart.next
        if start == nil { end = nil }
        return oldStart.element
    }
    
    @inlinable
    func removeFirst(_ k: Int) {
        guard let oldStart = start else {
            fatalError("removeFirst(_:) called on empty collection")
        }
        count -= k
        guard count >= 0 else {
            fatalError("not enough values to remove")
        }
        
        var newStart = oldStart.next
        for _ in 1 ..< k {
            newStart = newStart?.next
        }
        start = newStart
        if start == nil { end = nil }
    }
    
    @inlinable
    func insert(_ newElement: __owned T, at i: SwiftQueue<T>.Index) {
        checkIndex(i)
        
        let currentBox = getBoxForUncheckedIndex(i)
            
        
        let movedBox = Box(currentBox.element)!
        
        movedBox.next = currentBox.next
        currentBox.next = movedBox
        currentBox.element = newElement
        
        count += 1
    }
    
    
    /// Insert contents of another collection at index `i`
    ///
    /// - Note: The collection `newElements` is assumed to have at least one element.
    ///
    /// - Parameter newElements: The elements to insert.
    /// - Parameter i: The index at which the elements should be inserted.
    @inlinable
    func insert<C>(contentsOf newElements: __owned C, at i: SwiftQueue<T>.Index) where C : Collection, SwiftQueue<T>.Element == C.Element {
        
        checkIndex(i)
        
        let newCount = newElements.count
        
        guard newCount > 1 else {
            self.insert(newElements.first!, at: i)
            return
        }
        
        let queueToInsert = QueueStorage(newElements)
        
        let currentBox = getBoxForUncheckedIndex(i)
        
        let movedBox = Box(currentBox.element)!
        
        movedBox.next = currentBox.next
        
        let insertQueueStartBox = queueToInsert.start!
        
        currentBox.element = insertQueueStartBox.element
        currentBox.next = insertQueueStartBox.next
        
        let insertQueueEndBox = queueToInsert.end!
        
        insertQueueEndBox.next = movedBox
        
        count += newCount
        
    }
    
    @inlinable
    convenience init<S>(_ elements: S) where S : Sequence, T == S.Element {
        self.init()
        for element in elements {
            self.append(element)
        }
    }
    
    @inlinable
    convenience init(repeating repeatedValue: T, count: Int) {
        self.init()
        for _ in 0 ..< count {
            self.append(repeatedValue)
        }
    }
    
    @inlinable
    var first: T? { return start?.element }
}

extension QueueStorage {
    
    @inlinable
    internal convenience init(copying other: QueueStorage<T>) {
        self.init()
        self.count = other.count
        
        guard other.count > 0 else { return }
        
        self.start = Box(other.start!.element)
        var thisBox = self.start!
        var otherBox = other.start
        while let nextOtherBox = otherBox?.next {
            let nextBox = Box(nextOtherBox.element)!
            thisBox.next = nextBox
            thisBox = nextBox
            otherBox = nextOtherBox
        }
        self.end = thisBox
    }
    
    @inlinable
    internal func copy() -> QueueStorage {
        return QueueStorage(copying: self)
    }
}