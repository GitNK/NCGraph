# NCGraph
[![release](https://img.shields.io/badge/pod-v1.0.2-blue.svg)](https://img.shields.io/badge/pod-v1.0.2-blue.svg)
[![release](https://img.shields.io/badge/platforms-iOS%208.0%2B%20%7C%20macOS%2010.10%2B%20%7C%20tvOS%209.0%2B-lightgrey.svg)](https://img.shields.io/badge/platforms-iOS%208.0%2B%20%7C%20macOS%2010.10%2B%20%7C%20tvOS%209.0%2B-lightgrey.svg)
[![release](https://img.shields.io/badge/Swift-4-orange.svg)](https://img.shields.io/badge/Swift-4-orange.svg)

Graph data structure written in Swift 4 using protocol oriented programming technics.

## Features

- [x] Generic `Node` and `Edge` types
- [x] Generic `name` field for `Node` type
- [x] Minimum spanning tree (Primm's and Kruskal`s algorithms)
- [x] Topological sort
- [x] Check directed graph if its acyclic (DAG)
- [x] Check if graph is connected
- [x] Number of hops from source to target node
- [x] Find connected (for undirected) and strongly connected (for directed) graph components
- [x] Max spacing k-clustering
- [x] Single source shortest path (Dijkstra's and Bellman-Ford's algorithms)
- [x] All source shortest paths (Johnson's algorithm)
- [x] Binary Heap data structure
- [x] Union Find data structure

## Requirements

- iOS 8.0+, macOS 10.10+, tvOS 9.0+
- Xcode 8.0+
- Swift 4.0+

## Installation with CocoaPods
You can install it with the following comand: 

``` bash
$ gem install cocoapods
```
#### Podfile

To integrate NCGraph into your Xcode project using CocoaPods, specify it in your `Podfile`:

``` bash
source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.10'
use_frameworks!

target 'PodTest' do
pod 'NCGraph', '~> 1.0'
end
```
Then, run the following command:

```bash
$ pod install
```

### Manually

If you prefer you can integrate NCGraph into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
$ git init
```

- Add NCGraph as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
$ git submodule add https://github.com/GitNK/NCGraph.git
```

- Open the new `NCGraph` folder, and drag the `NCGraph.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `NCGraph.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `NCGraph.xcodeproj` folders each with two different versions of the `NCGraph.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `NCGraph.framework`.

- Select the top `NCGraph.framework` for iOS (or platform that you need).

- And that's it!

  > The `NCGraph.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

---

## Usage

### Initialize graph

```swift
  import NCGraph
  
  var graph = NCGraph<NCNode,NCEdge>(isDirected: true, allowParallelEdges: true)
```

Or you can make a clone of existent graph:
```swift
  var graph = NCGraph<NCNode,NCEdge>(graph: toClone)
```

### Adding a Node

Add node by its name, graph will cleate and add a new instance to self:

```swift
  graph.addNode(named: "Node_1")
```

or, you can add already created node:

```swift
graph.addNode(node: someNode)
```

If node with same name already present method will return false.

### Adding an Edge

You can add edges by name of the nodes, with already created node or with created edge instances:

```swift
  graph.addEdgeWith(tailName: "Node_1", headName: "Node_2", weight: 0)
```

```swift
  graph.addEdgeWith(tail: someNode_1, headName: someNode_2, weight: 0)
```

```swift
  graph.addEdge(someEdge)
```
For unweighted graphs set `0` for weight.

You can also add edges from an array:

```swift
  graph.addEdgesFrom(array: arrayOfEdges)
```
#### If you're adding edge with nodes or node names that are not present in graph they will be automatically added.

### Using algorithms

After loading nodes and edges you can use any of given algorithms. Make sure you've created appropriate type for graph (directed or undirected, parallel or no parrallel edges). You can read method descriptions for any specific, if any, requiremnts.

#### Shortest path example

```swift
var shortestPath = graph.spFrom(source: sourceNode, algorithm: .dijkstra)
```

### `NCNode` and `NCEdge` types

These are default node and edge types. If you don't need to use your custom classes with `NCGraph` you can use these classes instead. `NCNodes` name field is of type 'String'. You can set any type for name in your custom class.

### Initialize NCNode

You can init with name:
```swift
let node_1 = NCNode(name: "My Node")
```

Or with previously created node:
```swift
let node_2 = NCNode(someNode)
```

### Initialize NCEdge

Initialization with weight, tail and head names:
```swift 
let edge = NCEdge(tailName: "First", headName: "Second", weight: 100)
```
If you ommit weight it will be automatically set to 0:
```swift
let edge_2 = NCEdge(tail: someNode_1, head: someNode_2)
```
Initialize from existing edge:
```swift
let edge_3 = NCEdge(edge: someEdge)
```

### Custom `Node` and `Edge` types

In order to use NCGraph structure with custom node and edge types they should conform to following public protocols:

#### Node
```swift
/// Protocol for custom `Node` types can be usable in `NCGraph`
public protocol NCNodeProtocol: Comparable {
    
    associatedtype Name:Hashable
    
    var name: Name {get}
    
    init(name: Name)
    init(node: Self)
    
    static func ==(lhs: Self, rhs: Self) -> Bool
    static func <(lhs: Self, rhs: Self) -> Bool
}
```
#### Edge
```swift
/// Protocol for custom `Edge` types that can be used in `NCGraph`
public protocol NCEdgeProtocol {
    
    associatedtype NodeType:NCNodeProtocol
    
    var tail: NodeType {get}
    var head: NodeType {get}
    var weight: Int {get set}
    
    init(tail: NodeType, head: NodeType, weight: Int)
    init(edge: Self)
    
    static func ==(lhs: Self, rhs: Self) -> Bool
    static func <(lhs: Self, rhs: Self) -> Bool
}
```

Or if you don't need custom classes you can use already implemented default classes: `NCNode`, `NCEdge`

## Release History
* 1.0.2
    * Updated to Swift 4
* 1.0.1
    * Added support for macOS and tvOS
* 1.0.0
    * Initial release

## License
NCGraph is released under the MIT license. See LICENSE for details.
