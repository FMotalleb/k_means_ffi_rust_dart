#[derive(Debug, Clone)]
#[repr(C)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

#[derive(Debug, Clone)]
#[repr(C)]
pub struct KMeansResultRow {
    pub points: Point,
    pub source_indexes: Vec<i32>,
}
