#[derive(Debug, Clone)]
#[repr(C)]
pub struct PointPub {
    pub x: f64,
    pub y: f64,
}

#[derive(Debug, Clone)]
#[repr(C)]
pub struct KMeansResultRow {
    pub point: PointPub,
    pub source_indexes: Vec<i32>,
}
