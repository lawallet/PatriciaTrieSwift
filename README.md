# PatriciaTrieSwift
Swift implementation of a Patricia Trie. Supports adding and deleting strings. Taken from an image board application I wrote where I used it for an autocomplete feature.


## Code Example

```swift
let patriciaTrie = SwiftTrie()
// Insert a string
let didInsert = patriciaTrie.insertString("Banana")
// Search for all strings containing ban
let containBan = patriciaTrie.getAllStringsForPrefix("ban")
// Delete a string
let didDelete = patriciaTrie.deleteString("Banana")
```

