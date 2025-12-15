# OLE图像配准系统 (Optical-Infrared Image Registration)

## 项目简介

这是一个基于OLE (Optical-Infrared) 算法的图像配准系统，主要用于可见光和红外图像的自动配准。该系统实现了粗配准和精配准相结合的两阶段配准策略，能够有效处理多模态图像的配准问题。

## 主要特性

- **两阶段配准策略**: 粗配准 + 精配准
- **多模态图像支持**: 可见光-红外图像配准
- **鲁棒特征提取**: 基于相位一致性和CFOG特征
- **非线性变换**: TPS (Thin Plate Spline) 变换支持
- **高精度匹配**: 结合互信息和相关性的综合评价

## 算法流程

1. **粗配准阶段**:
   - 基于SSIM和RMSE的尺度搜索
   - 相位一致性特征提取
   - LACE图像增强
   - Harris角点检测
   - 互信息和RMSE综合评价

2. **精配准阶段**:
   - CFOG特征提取
   - FFT相关匹配
   - 子像素级精度优化

3. **几何变换**:
   - TPS薄板样条变换
   - 图像融合和镶嵌

## 文件结构

```
├── main.m                    # 主程序入口
├── Functions/                # 函数库
│   ├── coarseRegistrationSSIMRMSE.m    # 粗配准函数
│   ├── fineRegistrationCFOG.m          # 精配准函数
│   ├── TPStransformation.m             # TPS变换函数
│   ├── phasecong3.m                    # 相位一致性特征
│   ├── LACEgray.m                      # LACE灰度增强
│   ├── mutualInformation.m             # 互信息计算
│   ├── CFOGmatlab1.m                   # CFOG特征提取
│   ├── fftMatch.m                      # FFT匹配
│   ├── HMransac.m                      # RANSAC算法
│   └── residualKRrobust.m              # KR鲁棒残差
├── data/                    # 测试数据
│   ├── vis1_v2.jpg         # 可见光图像
│   ├── ir1.jpg            # 红外图像
│   └── ...
└── README.md               # 说明文档
```

## 使用方法

### 环境要求

- MATLAB R2018b 或更高版本
- Image Processing Toolbox

### 运行步骤

1. **设置参数**:
   ```matlab
   pointNum = 100;  % 特征点数量
   batchSize = 80;  % 批处理窗口大小
   imNum = 4;       % 测试图像对编号
   ```

2. **运行主程序**:
   ```matlab
   main  % 直接运行main.m
   ```

3. **查看结果**:
   - 程序会自动显示配准过程中的可视化结果
   - 最终输出镶嵌图像和运行时间

## 参数说明

- `pointNum`: 粗配准阶段提取的特征点数量
- `batchSize`: 精配准阶段的局部窗口大小
- `imNum`: 测试图像对的编号 (1-19)

## 输出结果

- **可视化结果**:
  - 粗配准特征点可视化
  - 精配准匹配结果
  - 最终配准镶嵌图像

- **定量评价** (可选):
  - RMSE (均方根误差)
  - 平均定位误差
  - 最大定位误差

## 核心算法

### 粗配准算法

基于多尺度搜索和综合评价的粗配准方法：

1. 尺度空间搜索 (1.0-1.5倍)
2. 相位一致性特征 + LACE增强
3. Harris角点检测
4. 互信息(MI)和RMSE的加权综合评价

### 精配准算法

基于CFOG特征的子像素级精配准：

1. CFOG特征提取
2. 局部FFT相关匹配
3. 子像素精度优化

### TPS变换

基于薄板样条的非线性几何变换：

1. RANSAC内点筛选
2. KR相机模型参数估计
3. TPS插值变换
4. 平滑过渡融合

## 参考文献

该实现基于以下论文和算法：

- Phase Congruency特征提取
- CFOG (Compact Feature of Oriented Gradients)
- LACE (Local Adaptive Contrast Enhancement)
- TPS (Thin Plate Spline) 变换
- RANSAC算法

## 许可证

本项目仅供学术研究使用。

## 联系方式

如有问题或建议，请联系项目维护者。
