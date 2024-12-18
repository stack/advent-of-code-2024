//
//  GraphTests.swift
//  Advent of Code 2024 Testing
//
//  Created by Stephen H. Gerstacker on 2024-12-17.
//  SPDX-License-Identifier: MIT
//

import Testing

@testable import AdventOfCode

struct GraphTests {
    
    let point1 = Point(x: 1, y: 2)
    let point2 = Point(x: 3, y: 4)
    let point3 = Point(x: 5, y: 6)

    @Test func insert() {
        // Given an empty graph
        var graph = Graph<Point, Direction>()
        
        // Then the graph should report being empty
        #expect(graph.count == 0)
        
        // When adding a vertex
        graph.insert(point1)
        
        // Then the count should be incremented
        #expect(graph.count == 1)
    }
    
    @Test func remove() {
        // Given a graph with a vertex
        var graph = Graph<Point, Direction>()
        graph.insert(point1)
        
        // When the vertex is removed
        graph.remove(point1)
        
        // Then the count should report being empty
        #expect(graph.count == 0)
    }
    
    @Test func addEdge() throws {
        // Given a graph with two vertices
        var graph = Graph<Point, Direction>()
        graph.insert(point1)
        graph.insert(point2)
        
        // When an edge is added from the 1st to 2nd
        graph.addEdge(type: .north, from: point1, to: point2, weight: 10)
        
        // Then the edge can be retrieved
        let result = try #require(graph.edge(type: .north, from: point1))
        
        #expect(result.0 == point2)
        #expect(result.1 == 10)
    }
    
    @Test func removeEdge() {
        // Given a graph with two vertices and an edge
        var graph = Graph<Point, Direction>()
        graph.insert(point1)
        graph.insert(point2)
        graph.addEdge(type: .north, from: point1, to: point2, weight: 10)
        
        // When the edge is removed
        graph.removeEdge(type: .north, from: point1)
        
        // Then the edge cannot be retrieved
        #expect(graph.edge(type: .north, from: point1) == nil)
    }
    
    @Test func removeVertexWithEdges() {
        // Given a graph with two vertices and an edge
        var graph = Graph<Point, Direction>()
        graph.insert(point1)
        graph.insert(point2)
        graph.addEdge(type: .north, from: point1, to: point2, weight: 10)
        graph.addEdge(type: .south, from: point2, to: point1, weight: 10)
        
        // When a vertex is removed
        graph.remove(point1)
        
        // Then the edges from that point are removed
        #expect(graph.edge(type: .north, from: point1) == nil)
        
        // Then the edges to that point are removed
        #expect(graph.edge(type: .south, from: point2) == nil)
    }
    
    @Test func totalEdges() {
        // Given a graph with multiple nodes and edges
        var graph = Graph<Point, Direction>()
        graph.insert(point1)
        graph.insert(point2)
        graph.insert(point3)
        graph.addEdge(type: .north, from: point1, to: point2, weight: 1)
        graph.addEdge(type: .south, from: point2, to: point1, weight: 2)
        graph.addEdge(type: .east, from: point1, to: point3, weight: 3)
        
        // When point 1 is inspect, then the count should be 2
        #expect(graph.totalEdges(from: point1) == 2)
        
        // When point 2 is inspected, then the count should be 1
        #expect(graph.totalEdges(from: point2) == 1)
        
        // When point 3 is inspected, then the count should be 0
        #expect(graph.totalEdges(from: point3) == 0)
    }
    
    @Test func findFirst() throws {
        // Given a graph with multiple nodes and edges
        var graph = Graph<Point, Direction>()
        graph.insert(point1)
        graph.insert(point2)
        graph.insert(point3)
        graph.addEdge(type: .north, from: point1, to: point2, weight: 1)
        graph.addEdge(type: .south, from: point2, to: point1, weight: 2)
        graph.addEdge(type: .east, from: point1, to: point3, weight: 3)
        
        // When an existing point is searched for, then the point is returned
        let firstPoint = try #require(graph.first(where: { graph.totalEdges(from: $0) == 0 }))
        #expect(firstPoint == point3)
        
        // When a non-existing point is search for, then nil is returned
        #expect(graph.first(where: { $0 == .zero }) == nil)
    }
}
