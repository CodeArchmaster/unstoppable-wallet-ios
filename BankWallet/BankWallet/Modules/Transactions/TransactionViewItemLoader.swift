import DeepDiff

class TransactionViewItemLoader {
    let queue: DispatchQueue
    let state: TransactionViewItemLoaderState
    let differ: IDiffer

    weak var delegate: ITransactionViewItemLoaderDelegate?

    init(state: TransactionViewItemLoaderState, differ: IDiffer, async: Bool = true) {
        self.state = state
        self.differ = differ
        queue = async ? DispatchQueue.global(qos: .userInteractive) : DispatchQueue.main
    }

}

extension TransactionViewItemLoader: ITransactionViewItemLoader {

    func reload(with newItems: [TransactionItem], animated: Bool) {
        queue.sync {
            var newViewItems = state.viewItems ?? []
            let itemsChanges = IndexPathConverter().convert(changes: differ.changes(old: state.items, new: newItems), section: 0)

            for index in itemsChanges.deletes.sorted().reversed() {
                newViewItems.remove(at: index.row)
            }
            for index in itemsChanges.inserts {
                if let viewItem = delegate?.createViewItem(for: newItems[index.row]) {
                    newViewItems.insert(viewItem, at: index.row)
                }
            }
            var updateIndexes = itemsChanges.moves.reduce([Int]()) {
                var updates = $0
                updates.append($1.from.row)
                updates.append($1.to.row)
                return updates
            }
            updateIndexes.append(contentsOf: itemsChanges.replaces.map { $0.row })
            for updatedIndex in updateIndexes {
                if let viewItem = delegate?.createViewItem(for: newItems[updatedIndex]) {
                    newViewItems[updatedIndex] = viewItem
                }
            }

            state.items = newItems
            state.viewItems = newViewItems
            self.delegate?.reload(with: newViewItems, animated: animated)
        }
    }

    func reloadAll() {
        queue.sync {
            var newViewItems = [TransactionViewItem]()
            for item in state.items {
                if let viewItem = delegate?.createViewItem(for: item) {
                    newViewItems.append(viewItem)
                }
            }

            state.viewItems = newViewItems
            self.delegate?.reload(with: newViewItems, animated: false)
        }
    }

    func reload(indexes: [Int]) {
        var updatedViewItems = state.viewItems ?? []

        queue.sync {
            for (index, item) in state.items.enumerated() {
                if indexes.contains(index), let viewItem = delegate?.createViewItem(for: item) {
                    updatedViewItems[index] = viewItem
                }
            }

            state.viewItems = updatedViewItems
            self.delegate?.reload(with: updatedViewItems, animated: true)
        }
    }

    func add(items: [TransactionItem]) {
        var updatedItems = state.items
        updatedItems.append(contentsOf: items)
        reload(with: updatedItems, animated: false)
    }

}
