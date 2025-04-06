package bglib.utils;
using Lambda;

/**
 * An edge connecting two nodes.
 **/
@:allow(bglib.utils.Graph)
@:structInit class Edge<N, E> {
    var n0:Node<N, E>;
    var n1:Node<N, E>;
    var data:E = null;

    /**
     * Returns the connecting node.
     * @param node key
     * @return Node<N, E>
     **/
    public function next(node:Node<N, E>):Node<N, E> {
        if (node == n0) return n1;
        if (node == n1) return n0;
        throw "node is not part of edge";
    }
}

/**
 * A node on the graph with data.
 **/
@:allow(bglib.utils.Graph)
class Node<N, E> {
    var edges:Array<Edge<N, E>>;
    var data:N;

    public function new(?data:N) {
        edges = [];
        this.data = data;
    }

    /**
     * Connects the nodes together.
     * @param node to connect
     * @param data of the edge
     * @return Edge<N, E>
     **/
    public function connect(node:Node<N, E>, ?data:E):Edge<N, E> {
        var edge:Edge<N, E> = {n0: this, n1:node, data:data};
        edges.push(edge);
        node.edges.push(edge);
        return edge;
    }

    /**
     * Removes the given edge.
     * @param edge to remove
     **/
    public function disconnect(edge:Edge<N, E>) {
        edges.remove(edge);
        edge.next(this).edges.remove(edge);
    }

    /**
     * Removes the connection to the given node.
     * @param node to remove
     * @return Edge<N, E>
     **/
    public function removeNode(node:Node<N, E>):Edge<N, E> {
        for (edge in edges) {
            if (edge.next(this) == node) {
                disconnect(edge);
                return edge;
            }
        }
        return null;
    }
}

/**
 * A basic graph.
 **/
class Graph<N, E> {
    var nodes:Array<Node<N, E>>;
    var edges:Array<Edge<N, E>>;

    public function new() {
        nodes = [];
        edges = [];
    }

    /**
     * Adds a node to the graph.
     * @param data of the node
     * @return Node<N, E>
     **/
    public function addNode(?data:N):Node<N, E> {
        var n = new Node(data);
        nodes.push(n);
        return n;
    }

    /**
     * Removes node from the graph.
     * @param node to remove
     **/
    public function removeNode(node:Node<N, E>) {
        nodes.remove(node);
        for (edge in node.edges) {
            edges.remove(edge);
            node.disconnect(edge);
        }
    }

    /**
     * Connects two nodes in the graph with an edge.
     * @param n0 node
     * @param n1 node
     * @param data of the edge
     * @return Edge<N, E>
     **/
    public function connect(n0:Node<N, E>, n1:Node<N, E>, ?data:E):Edge<N, E> {
        var edge = n0.connect(n1, data);
        edges.push(edge);
        return edge;
    }

    /**
     * Removes an edge from the graph.
     * @param edge to remove
     **/
    public function removeEdge(edge:Edge<N, E>) {
        edges.remove(edge);
        edge.n0.disconnect(edge);
    }

    /**
     * Generates a 4-connected orthogonal graph.
     * @param n the height
     * @param m the length
     * @return Graph<N, E>
     **/
    public static function orthogonal<N, E>(n:Int, m:Int):Graph<N, E> {
        var graph:Graph<N, E> = new Graph<N, E>();

        var prevLayer:Array<Node<N, E>> = [for (m in 0...m) new Node()];

        for (m in 1...m) {
            graph.connect(prevLayer[m-1], prevLayer[m]);
        }

        for (n in 0...n) {
            var layer:Array<Node<N, E>> = [for (m in 0...m) new Node()];

            for (m in 1...m) {
                graph.connect(layer[m-1], layer[m]);
            }

            for (m in 0...m) {
                graph.connect(layer[m], prevLayer[m]);
            }

            prevLayer = layer;
        }
        return graph;
    }
}