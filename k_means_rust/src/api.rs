use crate::data::{KMeansResultRow, Point};
use cogset::{Euclid, Kmeans};
pub fn kmeans(points: Vec<Point>, output_count: usize) -> Vec<KMeansResultRow> {
    let point_data: Vec<Euclid<[f64; 2]>> = cast_point_list_to_eculidvec(points);
    let kmeans: Vec<(Euclid<[f64; 2]>, Vec<usize>)> =
        Kmeans::new(&point_data, output_count).clusters();
    cast_cluster_to_result(kmeans)
}

fn cast_cluster_to_result(clusters: Vec<(Euclid<[f64; 2]>, Vec<usize>)>) -> Vec<KMeansResultRow> {
    let mut result: Vec<KMeansResultRow> = Vec::new();
    clusters
        .into_iter()
        .for_each(|(_point, _indexes): (Euclid<[f64; 2]>, Vec<usize>)| {
            let source: Vec<i32> = _indexes.into_iter().map(|x| x as i32).collect();
            let point: Point = Point {
                x: _point.0[0],
                y: _point.0[1],
            };
            result.push(KMeansResultRow {
                points: point,
                source_indexes: source,
            });
        });
    result
}

fn cast_point_list_to_eculidvec(points: Vec<Point>) -> Vec<Euclid<[f64; 2]>> {
    let mut result: Vec<Euclid<[f64; 2]>> = Vec::new();
    for i in points {
        result.push(Euclid([i.x, i.y]));
    }
    result
}
