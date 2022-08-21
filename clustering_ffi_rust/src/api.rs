use crate::data::{ClusteringResultStruct, PointStruct};
use cogset::{BruteScan, Euclid, Kmeans, Optics, OpticsDbscanClustering};
pub fn kmeans(points: Vec<PointStruct>, output_count: usize) -> Vec<ClusteringResultStruct> {
    let point_data: Vec<Euclid<[f64; 2]>> = cast_point_list_to_eculidvec(points);
    let kmeans: Vec<(Euclid<[f64; 2]>, Vec<usize>)> =
        Kmeans::new(&point_data, output_count).clusters();
    cast_cluster_to_result(kmeans)
}
pub fn optics(points: Vec<PointStruct>, eps: f64, min_pts: usize) -> Vec<ClusteringResultStruct> {
    let point_data: Vec<Euclid<[f64; 2]>> = cast_point_list_to_eculidvec(points.clone());
    let points_scan: BruteScan<Euclid<[f64; 2]>> = BruteScan::new(&point_data);
    let optics = Optics::new(points_scan, eps, min_pts);
    let optics_result: OpticsDbscanClustering<BruteScan<Euclid<[f64; 2]>>> =
        optics.dbscan_clustering(eps);

    cast_optics_to_result(points.clone(), optics_result)
}
fn cast_optics_to_result(
    input: Vec<PointStruct>,
    opt_result: OpticsDbscanClustering<BruteScan<Euclid<[f64; 2]>>>,
) -> Vec<ClusteringResultStruct> {
    let mut result: Vec<ClusteringResultStruct> = Vec::new();
    opt_result.into_iter().for_each(|indexes| {
        let selected_points: Vec<PointStruct> = input
            .iter()
            .enumerate()
            .filter(|(index, _)| indexes.contains(index))
            .map(|(_, point)| point.clone())
            .collect();
        let source: Vec<i32> = indexes.into_iter().map(|x: usize| x as i32).collect();
        let center: PointStruct = center_of(selected_points);
        let value: ClusteringResultStruct = ClusteringResultStruct {
            point: center,
            source_indexes: source,
        };
        result.push(value);
    });
    result
}

fn center_of(points: Vec<PointStruct>) -> PointStruct {
    let mut x_sum: f64 = 0.0;
    let mut y_sum: f64 = 0.0;
    let point_length: usize = points.len();
    points.into_iter().for_each(|point: PointStruct| {
        x_sum += point.x;
        y_sum += point.y;
    });
    PointStruct {
        x: x_sum / point_length as f64,
        y: y_sum / point_length as f64,
    }
}
fn cast_cluster_to_result(
    clusters: Vec<(Euclid<[f64; 2]>, Vec<usize>)>,
) -> Vec<ClusteringResultStruct> {
    let mut result: Vec<ClusteringResultStruct> = Vec::new();
    clusters
        .into_iter()
        .for_each(|(_point, _indexes): (Euclid<[f64; 2]>, Vec<usize>)| {
            let source: Vec<i32> = _indexes.into_iter().map(|x| x as i32).collect();
            let point: PointStruct = PointStruct {
                x: _point.0[0],
                y: _point.0[1],
            };
            result.push(ClusteringResultStruct {
                point: point,
                source_indexes: source,
            });
        });
    result
}

fn cast_point_list_to_eculidvec(points: Vec<PointStruct>) -> Vec<Euclid<[f64; 2]>> {
    let mut result: Vec<Euclid<[f64; 2]>> = Vec::new();
    for i in points {
        result.push(Euclid([i.x, i.y]));
    }
    result
}
