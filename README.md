# OLE图像配准系统

算法的可见光与红外图像配准系统。

## 项目结构

```
registration_OLE/
├── main.m                    # 主程序入口
├── Functions/                 # 函数库文件夹
│   ├── coarseRegistration.m   # 粗配准函数
│   ├── fineRegistration.m     # 精配准函数
│   ├── tpsTransform.m         # TPS变换函数
│   ├── cfog.m                 # CFOG特征描述符
│   ├── fftMatch.m             # FFT匹配
│   ├── homographyRansac.m     # 单应性矩阵RANSAC估计
│   ├── residualHomography.m   # 单应性残差计算
│   ├── residualKRRobust.m     # KR鲁棒残差计算
│   ├── laceGray.m             # LACE灰度增强
│   ├── llce.m                 # 局部对比度增强
│   ├── mutualInformation.m    # 互信息计算
│   ├── gaussFilter.m          # 高斯滤波
│   ├── boxFilter.m           # 盒式滤波
│   └── lowpassFilter.m       # 低通滤波
├── functions/                 # 第三方函数库（phasecong3等）
├── data/                      # 图像数据文件夹
└── README.md                  # 本文件
```

## 功能说明

### 主要功能模块

1. **粗配准（Coarse Registration）**
   - 基于相位一致性特征提取
   - 使用Harris角点检测
   - 通过互信息和RMSE综合得分优化尺度参数

2. **精配准（Fine Registration）**
   - 基于CFOG（Circular Frequency-Oriented Gradient）特征描述符
   - 使用FFT进行局部匹配
   - 对粗配准结果进行精细化

3. **弹性**
   - 基于弹性的非刚性变换
   - 实现图像配准和拼接
   - 支持重叠区域的平滑过渡

## 使用方法

1. **准备数据**
   - 将可见光图像放在 `data/` 文件夹，命名为 `vis{编号}_v2.jpg`
   - 将红外图像放在 `data/` 文件夹，命名为 `ir{编号}.jpg`

2. **运行主程序**
   ```matlab
   main.m
   ```

3. **参数设置**
   在 `main.m` 中可以修改以下参数：
   - `pointNum`: 每个网格块提取的特征点数量（默认100）
   - `batchSize`: 精配准匹配窗口大小（默认80）
   - `imNum`: 图像编号（默认1）



## 依赖说明

- MATLAB R2018b或更高版本
- Image Processing Toolbox
- Optimization Toolbox
- Statistics and Machine Learning Toolbox


## 注意事项

1. 确保 `functions/` 文件夹中包含 `phasecong3.m` 文件
2. 图像路径和文件名需要符合规范
3. 如果需要进行客观评价，需要准备 `c_points.mat` 文件



### 本文引用
如果我们的工作对您有帮助，请引用我们的论文：

```bibtex
@article{li2026ecpcs,
  title={ECPCS: Enhanced contrast phase consistency space for visible and infrared image registration},
  author={Li, Hao and Liu, Chenhua and Li, Maoyong and Deng, Lei and Dong, Mingli and Zhu, Lianqing},
  journal={Optics and Lasers in Engineering},
  volume={197},
  pages={109472},
  year={2026},
  publisher={Elsevier}
}
```


```bibtex
@article{li2025cross,
  title={Cross-scale infrared and visible image registration based on phase consistency feature for UAV scenario},
  author={Li, Hao and Liu, Chenhua and Li, Maoyong and Deng, Lei and Dong, Mingli and Zhu, Lianqing},
  journal={Measurement},
  pages={119340},
  year={2025},
  publisher={Elsevier}
}
```

