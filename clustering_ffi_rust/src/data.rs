#[derive(Debug, Clone)]
#[repr(C)]
pub struct PointStruct {
    pub x: f64,
    pub y: f64,
}

#[derive(Debug, Clone)]
#[repr(C)]
pub struct ClusteringResultStruct {
    pub point: PointStruct,
    pub source_indexes: Vec<i32>,
}
