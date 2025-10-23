#include "ads1118.h"

/* 私有变量 */
static SPI_HandleTypeDef *ads1118_hspi;
static ADS1118_ConfigTypeDef ads1118_config;

/* 私有函数声明 */
static uint16_t ADS1118_ReadWrite(uint16_t data);
static ADS1118_StatusTypeDef ADS1118_WriteConfig(void);

/**
 * @brief 通过SPI读写数据
 * @param data 要发送的数据
 * @return 读取到的数据
 */
static uint16_t ADS1118_ReadWrite(uint16_t data)
{
    uint16_t rx_data = 0;

    if (HAL_SPI_TransmitReceive(ads1118_hspi, (uint8_t *)&data, (uint8_t *)&rx_data, 1, HAL_MAX_DELAY) != HAL_OK) {
        return 0xFFFF;
    }

    return rx_data;
}

/**
 * @brief 写入配置到ADS1118
 * @return 操作状态
 */
static ADS1118_StatusTypeDef ADS1118_WriteConfig(void)
{
    uint16_t config_reg = 0;
    uint16_t rx_data    = 0;

    /* 构造配置寄存器值 */
    config_reg |= ads1118_config.mux;
    config_reg |= ads1118_config.pga;
    config_reg |= ads1118_config.mode;
    config_reg |= ads1118_config.rate;
    config_reg |= ads1118_config.dataType;
    config_reg |= 0x0002; /* 必须为1的位 */

    /* 发送配置 */
    rx_data = ADS1118_ReadWrite(config_reg);

    /* 检查返回值是否正确 */
    if (rx_data == 0xFFFF) {
        return ADS1118_ERROR;
    }

    return ADS1118_OK;
}

/**
 * @brief 初始化ADS1118
 * @param hspi SPI句柄指针
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_Init(SPI_HandleTypeDef *hspi)
{
    if (hspi == NULL) {
        return ADS1118_ERROR;
    }

    ads1118_hspi = hspi;

    /* 设置默认配置 */
    ADS1118_SetDefaultConfig();

    return ADS1118_OK;
}

/**
 * @brief 配置ADS1118参数
 * @param config 配置参数结构体指针
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_Config(const ADS1118_ConfigTypeDef *config)
{
    if (config == NULL) {
        return ADS1118_ERROR;
    }

    /* 更新配置 */
    ads1118_config = *config;

    /* 写入配置到芯片 */
    return ADS1118_WriteConfig();
}

/**
 * @brief 启动一次ADC转换
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_StartConversion(void)
{
    uint16_t dummy   = 0xFFFF;
    uint16_t rx_data = 0;

    /* 发送dummy数据以启动转换 */
    rx_data = ADS1118_ReadWrite(dummy);

    if (rx_data == 0xFFFF) {
        return ADS1118_ERROR;
    }

    return ADS1118_OK;
}

/**
 * @brief 读取ADC转换结果
 * @param value 读取到的ADC值指针
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_ReadADCValue(int16_t *value)
{
    uint16_t config_reg = 0;
    uint16_t rx_data    = 0;

    if (value == NULL) {
        return ADS1118_ERROR;
    }

    /* 构造配置寄存器值，用于读取ADC值 */
    config_reg |= ads1118_config.mux;
    config_reg |= ads1118_config.pga;
    config_reg |= ads1118_config.mode;
    config_reg |= ads1118_config.rate;
    config_reg |= ADS1118_DATA_ADC; /* 读取ADC数据 */
    config_reg |= 0x0002;           /* 必须为1的位 */

    /* 发送配置并读取ADC值 */
    rx_data = ADS1118_ReadWrite(config_reg);

    if (rx_data == 0xFFFF) {
        return ADS1118_ERROR;
    }

    /* 提取ADC值（高16位为有效数据） */
    *value = (int16_t)(rx_data >> 0);

    return ADS1118_OK;
}

/**
 * @brief 读取温度传感器值
 * @param temp 温度值指针(单位:摄氏度)
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_ReadTemperature(float *temp)
{
    uint16_t config_reg = 0;
    uint16_t rx_data    = 0;

    if (temp == NULL) {
        return ADS1118_ERROR;
    }

    /* 构造配置寄存器值，用于读取温度值 */
    config_reg |= ads1118_config.mux;
    config_reg |= ads1118_config.pga;
    config_reg |= ads1118_config.mode;
    config_reg |= ads1118_config.rate;
    config_reg |= ADS1118_DATA_TEMP; /* 读取温度数据 */
    config_reg |= 0x0002;            /* 必须为1的位 */

    /* 发送配置并读取温度值 */
    rx_data = ADS1118_ReadWrite(config_reg);

    if (rx_data == 0xFFFF) {
        return ADS1118_ERROR;
    }

    /* 转换温度值 */
    /* 温度计算公式：Temp = (ADC_Code * 0.03125) °C */
    *temp = ((int16_t)rx_data) * 0.03125f;

    return ADS1118_OK;
}

/**
 * @brief 设置默认配置
 * @return 操作状态
 */
ADS1118_StatusTypeDef ADS1118_SetDefaultConfig(void)
{
    /* 默认配置 */
    ads1118_config.mux      = ADS1118_MUX_AIN0_AIN1;
    ads1118_config.pga      = ADS1118_PGA_2_048V;
    ads1118_config.mode     = ADS1118_MODE_SINGLE_SHOT;
    ads1118_config.rate     = ADS1118_RATE_128SPS;
    ads1118_config.dataType = ADS1118_DATA_ADC;

    return ADS1118_WriteConfig();
}