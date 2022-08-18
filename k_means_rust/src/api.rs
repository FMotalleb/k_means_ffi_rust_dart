#![allow(unused_variables)]

use crate::data::{KMeansResultRow, Point};
use cogset::{Euclid, Kmeans};
pub fn kmeans() -> Vec<KMeansResultRow> {
    let data = [
        Euclid([0.0, 0.0]),
        Euclid([1.0, 0.5]),
        Euclid([0.2, 0.2]),
        Euclid([0.3, 0.8]),
        Euclid([0.0, 1.0]),
        Euclid([0.2, 0.2]),
        Euclid([0.3, 0.8]),
        Euclid([0.0, 1.0]),
        Euclid([0.2, 0.2]),
        Euclid([0.3, 0.8]),
        Euclid([0.0, 1.0]),
        Euclid([0.2, 0.2]),
        Euclid([0.3, 0.8]),
        Euclid([0.0, 1.0]),
        Euclid([0.2, 0.2]),
    ];
    let k = 3;

    let kmeans: Vec<(Euclid<[f64; 2]>, Vec<usize>)> = Kmeans::new(&data, k).clusters();
    let mut result = Vec::new();
    for cluster in kmeans {
        let source = cluster.1;
        let point = Point {
            x: cluster.0 .0[0],
            y: cluster.0 .0[1],
        };
        result.push(KMeansResultRow {
            points: point,
            source_indexes: source,
        });
    }
    result
}
