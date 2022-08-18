#[derive(Debug, Clone)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

#[derive(Debug, Clone)]
pub struct KMeansResultRow {
    pub points: Point,
    pub source_indexes: Vec<usize>,
}
