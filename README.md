# 量化回测系统

专业的股票量化回测平台，支持自定义策略、多股票同时回测、可视化分析。

## 功能特点

- **数据获取**: 腾讯财经接口，多线程断点续传下载
- **数据分类**: 个股数据 + 大盘指数，命名格式 `代码_名称.csv`
- **技术指标**: 后端Python计算MA、MACD、KDJ、RSI、布林带等
- **策略系统**: 可视化配置 + Python代码两种模式
- **止损止盈**: 可自定义开关和比例
- **买入模式**: 固定金额、固定手数、仓位比例、满仓买入
- **回测引擎**: 多线程并行回测，速度快
- **可视化**: K线图、买卖点标记（B/S点）、收益分析

## 环境要求

- Python 3.8+
- Node.js 16+

## 快速开始

### 1. 安装依赖

双击 `start.bat`，选择 `1` 安装依赖。

或手动安装：
```bash
# 后端
cd backend
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 前端
cd frontend
npm install
```

### 2. 下载股票数据

```bash
cd backend
python data_fetcher.py
```

选择 `1` 下载所有A股数据（约4000只 + 大盘指数）。

数据下载特性：
- 多线程并发下载（默认20线程）
- 断点续传（中断后可继续）
- 自动跳过已下载文件
- 进度保存在 `data/download_progress.json`

### 3. 启动系统

双击 `start.bat`，选择 `5` 启动全部服务。

或手动启动：
```bash
# 后端
cd backend
python main.py

# 前端
cd frontend
npm run dev
```

### 4. 访问系统

- 前端界面: http://localhost:5173
- 接口文档: http://localhost:8080/接口文档

## 数据存储

```
backend/
├── data/
│   ├── 个股/           # 个股数据
│   │   ├── 000001_平安银行.csv
│   │   ├── 601318_中国平安.csv
│   │   └── ...
│   ├── 大盘/           # 大盘指数
│   │   ├── 000001_上证指数.csv
│   │   ├── 399001_深证成指.csv
│   │   └── ...
│   └── download_progress.json  # 下载进度
├── strategies/         # 策略配置
│   └── xxxxxxxx.json
└── backtest_results/   # 回测结果
    └── xxxxxxxx.json
```

## 使用说明

### 创建策略

1. 点击"策略管理" → "创建策略"
2. 选择策略类型：
   - **可视化策略**: 界面选择指标和条件，支持排除ST/科创板/创业板/北交所
   - **代码策略**: 编写Python代码

### 代码策略示例

```python
# signal_type: 'select'(选股), 'buy'(买入), 'sell'(卖出)
# 可用变量: df, index, row, prev_row, signal_type

if signal_type == 'select':
    # 选股: 成交量放大且收阳线
    if 成交量 > VOL5 * 1.5 and 收盘价 > 开盘价:
        result = True

elif signal_type == 'buy':
    # 买入: MA5上穿MA10
    if prev_row['MA5'] <= prev_row['MA10'] and MA5 > MA10:
        result = True

elif signal_type == 'sell':
    # 卖出: MA5下穿MA10
    if prev_row['MA5'] >= prev_row['MA10'] and MA5 < MA10:
        result = True
```

#### 涨停回调策略示例

系统已内置"涨停回调策略"，文件位于 `backend/strategies/zhangting_callback.json`

策略逻辑：
- **选股条件**：四天内有涨停板，第二天成交量是第一天两倍且收阴线，后面1-3天连续缩量且不破第一天涨停最低价
- **买入条件**：后面1-3天连续缩量且不破第一天涨停最低价买入
- **卖出条件**：
  - 破涨停最低价5%
  - 或涨幅超20%
  - 或涨幅超8%且收阴线且成交量放量
- **排除板块**：ST股票、科创板、创业板、北交所

可在策略管理中导入此策略进行回测。

### 买入模式

| 模式 | 说明 | 买入值 |
|------|------|--------|
| 固定金额 | 每次买入固定金额 | 金额(元) |
| 固定手数 | 每次买入固定手数 | 手数 |
| 仓位比例 | 按可用资金比例 | 0-1 |
| 满仓买入 | 全部资金买入 | 无需设置 |

### 止损止盈

- 回测时可开启/关闭止损止盈
- 止损比例：默认5%，可自定义
- 止盈比例：默认10%，可自定义
- 交易记录中会标注卖出原因

## 项目结构

```
量化回测系统/
├── backend/                    # 后端
│   ├── app/
│   │   ├── api/               # API路由（中文接口）
│   │   ├── services/          # 业务逻辑
│   │   │   ├── data_service.py    # 数据服务
│   │   │   ├── indicators.py      # 技术指标
│   │   │   └── backtest_engine.py # 回测引擎
│   ├── data/                  # 股票数据
│   ├── strategies/            # 策略配置
│   ├── data_fetcher.py        # 数据下载脚本
│   └── main.py                # 后端入口
├── frontend/                  # 前端
│   └── src/
│       ├── pages/            # 页面组件
│       └── services/         # API服务
├── start.bat                  # 启动脚本
└── README.md                  # 本文件
```

## 技术栈

**后端**
- FastAPI - Web框架
- Pandas - 数据处理
- NumPy - 数值计算

**前端**
- React 18
- Ant Design 5 - UI组件
- ECharts - 图表可视化
- Vite - 构建工具

## 配置说明

### 回测引擎配置

`backend/app/services/backtest_engine.py`

```python
# 历史数据获取天数（用于计算技术指标）
calc_start_dt = start_dt - timedelta(days=60)

# 数据长度检查（至少1条数据）
if df.empty or len(df) < 1:
    return None

# 选股条件检查范围（检查所有数据）
for i in range(1, len(df)):
    # ...
```

### 技术指标配置

`backend/app/services/indicators.py`

```python
# 均线周期
periods = [5, 10, 20, 30, 60, 120, 250]

# MACD参数
exp1 = df["收盘价"].ewm(span=12, adjust=False).mean()
exp2 = df["收盘价"].ewm(span=26, adjust=False).mean()

# RSI周期
rsi_period = 14
```

### 图表配置

`frontend/src/pages/BacktestDetail.jsx`

```javascript
// 图表高度计算
const chartHeight = 520 + (indicators.MACD ? 140 : 0) + 
                    (indicators.KDJ ? 140 : 0) + (indicators.RSI ? 140 : 0)

// dataZoom配置
dataZoom: [
  { type: 'inside', xAxisIndex: allXAxisIndices, start: 70, end: 100 },
  { show: true, type: 'slider', height: 20, bottom: 5, start: 70, end: 100 },
]
```

## 常见问题

**Q: 下载中断了怎么办？**
A: 直接重新运行，会自动跳过已下载的文件，继续下载未完成的部分。

**Q: 如何重新下载所有数据？**
A: 运行 `data_fetcher.py`，选择 `4` 重置下载进度，然后重新选择 `1` 下载。

**Q: 回测速度慢怎么办？**
A: 减少回测股票数量，或增加电脑内存。

**Q: 如何添加新的技术指标？**
A: 编辑 `backend/app/services/indicators.py`。

## 注意事项

- 本系统仅供学习和研究使用
- 股票投资有风险，请谨慎决策
- 数据来源于腾讯财经，仅供参考

## 开发日志

### 已修复问题

1. **图表显示优化**
   - K线图tooltip与个股详情页保持一致
   - 添加"昨收"数据显示
   - 修复slider重叠问题（bottom: 5, height: 20）

2. **技术指标**
   - MA5、MA10、MA20、MA60可独立显示
   - 支持BOLL、MACD、KDJ、RSI指标
   - 图表高度动态计算（520 + 子图数 × 140）

3. **回测日期范围**
   - 前端RangePicker正确绑定到Form
   - 日期格式化为YYYY-MM-DD
   - 后端正确传递start_date和end_date

4. **技术指标计算优化**
   - 移除20条数据限制，根据可用数据量计算指标
   - 均线不足周期时返回NaN而非不计算
   - MACD需要≥26条数据，KDJ/RSI需要≥9条数据

5. **数据获取优化**
   - 回测时在开始日期前多获取60天历史数据
   - 确保技术指标有足够的数据进行计算

### 已知问题

1. **短期数据回测结果为空**
   - 症状：设置较短的日期范围（如20天）时，回测结果显示0只股票、0笔交易
   - 原因：选股条件（如MA5上穿MA10）在短期数据中可能不满足
   - 临时解决：设置更长的日期范围（建议至少30天）
   - 测试脚本：`backend/test_filter.py` 可验证数据和指标计算是否正常

2. **未选择股票时默认行为**
   - 当前：未选择股票时默认测试600017日照港
   - 建议：在前端选择特定股票再运行回测

### 文件修改记录

| 文件 | 修改内容 |
|------|----------|
| `BacktestDetail.jsx` | 图表高度计算、slider配置、dataZoom起始值70% |
| `BacktestRun.jsx` | RangePicker绑定onChange事件、日期处理 |
| `backtest.py` | 日期处理、调试信息、默认测试股票 |
| `backtest_engine.py` | 数据长度检查、选股条件检查范围、历史数据获取 |
| `indicators.py` | 指标计算不再需要20条数据限制 |
| `data_service.py` | 移除os.makedirs阻塞调用 |

### 调试方法

```bash
# 测试数据获取和指标计算
cd backend
python test_filter.py

# 测试选股条件
python test_select.py

# 测试完整回测
python test_600017.py
```
