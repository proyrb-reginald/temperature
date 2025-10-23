#ifndef __ADS1118_H__
#define __ADS1118_H__

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"

/**
 * @brief ADS1118操作状态枚举
 */
typedef enum {
    ADS1118_OK = 0,
    ADS1118_ERROR
} ADS1118_StatusTypeDef;

/**
 * @brief ADS1118输入通道选择
 */
typedef enum {
    ADS1118_MUX_AIN0_AIN1 = 0x0000, /*!< 差分输入 AIN0-AIN1 */
    ADS1118_MUX_AIN0_AIN3 = 0x1000, /*!< 差分输入 AIN0-AIN3 */
    ADS1118_MUX_AIN1_AIN3 = 0x2000, /*!< 差分输入 AIN1-AIN3 */
    ADS1118_MUX_AIN2_AIN3 = 0x3000, /*!< 差分输入 AIN2-AIN3 */
    ADS1118_MUX_AIN0_GND  = 0x4000, /*!< 单端输入 AIN0-GND */
    ADS1118_MUX_AIN1_GND  = 0x5000, /*!< 单端输入 AIN1-GND */
    ADS1118_MUX_AIN2_GND  = 0x6000, /*!< 单端输入 AIN2-GND */
    ADS1118_MUX_AIN3_GND  = 0x7000  /*!< 单端输入 AIN3-GND */
} ADS1118_MuxTypeDef;

/**
 * @brief ADS1118 PGA增益设置
 */
typedef enum {
    ADS1118_PGA_6_144V = 0x0000, /*!< ±6.144V range */
    ADS1118_PGA_4_096V = 0x0200, /*!< ±4.096V range */
    ADS1118_PGA_2_048V = 0x0400, /*!< ±2.048V range */
    ADS1118_PGA_1_024V = 0x0600, /*!< ±1.024V range */
    ADS1118_PGA_0_512V = 0x0800, /*!< ±0.512V range */
    ADS1118_PGA_0_256V = 0x0A00  /*!< ±0.256V range */
} ADS1118_PgaTypeDef;

/**
 * @brief ADS1118数据采样速率
 */
typedef enum {
    ADS1118_RATE_8SPS   = 0x0000, /*!< 8 samples per second */
    ADS1118_RATE_16SPS  = 0x0020, /*!< 16 samples per second */
    ADS1118_RATE_32SPS  = 0x0040, /*!< 32 samples per second */
    ADS1118_RATE_64SPS  = 0x0060, /*!< 64 samples per second */
    ADS1118_RATE_128SPS = 0x0080, /*!< 128 samples per second */
    ADS1118_RATE_250SPS = 0x00A0, /*!< 250 samples per second */
    ADS1118_RATE_475SPS = 0x00C0, /*!< 475 samples per second */
    ADS1118_RATE_860SPS = 0x00E0  /*!< 860 samples per second */
} ADS1118_RateTypeDef;

/**
 * @brief ADS1118操作模式
 */
typedef enum {
    ADS1118_MODE_SINGLE_SHOT = 0x0100, /*!< 单次转换模式 */
    ADS1118_MODE_CONTINUOUS  = 0x0000  /*!< 连续转换模式 */
} ADS1118_ModeTypeDef;

/**
 * @brief ADS1118数据类型选择
 */
typedef enum {
    ADS1118_DATA_ADC  = 0x0000, /*!< ADC数据 */
    ADS1118_DATA_TEMP = 0x0100  /*!< 温度传感器数据 */
} ADS1118_DataTypeDef;

/**
 * @brief ADS1118配置结构体
 */
typedef struct {
    ADS1118_MuxTypeDef mux;       /*!< 输入通道选择 */
    ADS1118_PgaTypeDef pga;       /*!< PGA增益设置 */
    ADS1118_ModeTypeDef mode;     /*!< 操作模式 */
    ADS1118_RateTypeDef rate;     /*!< 采样速率 */
    ADS1118_DataTypeDef dataType; /*!< 数据类型 */
} ADS1118_ConfigTypeDef;

/**
 * @brief 初始化ADS1118
 * @param hspi SPI句柄指针
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_Init(SPI_HandleTypeDef *hspi);

/**
 * @brief 配置ADS1118参数
 * @param config 配置参数结构体指针
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_Config(const ADS1118_ConfigTypeDef *config);

/**
 * @brief 启动一次ADC转换
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_StartConversion(void);

/**
 * @brief 读取ADC转换结果
 * @param value 读取到的ADC值指针
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_ReadADCValue(int16_t *value);

/**
 * @brief 读取温度传感器值
 * @param temp 温度值指针(单位:摄氏度)
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_ReadTemperature(float *temp);

/**
 * @brief 设置默认配置
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_SetDefaultConfig(void);

#ifdef __cplusplus
}
#endif

#endif /* __ADS1118_H__ */