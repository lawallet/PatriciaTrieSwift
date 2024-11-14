# PatriciaTrieSwift
Swift implementation of a Patricia Trie. Supports adding and deleting strings. Taken from an image board application I wrote where I used it for an autocomplete feature.


## Code Example

```swift
let patriciaTrie = SwiftTrie()
// Insert a string
let didInsert = patriciaTrie.insertString("Banana")
// Search for all strings containing ban
let containBan = patriciaTrie.getAllStringsForPrefix("Ban")
// Delete a string
let didDelete = patriciaTrie.deleteString("Banana")
```

## Upcoming Features
- Convert from returning a boolean to using errors for inserting and deleting
- Enable better multithreading support if modifying the trie
