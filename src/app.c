#include "main.h"
#include "i2c.h"
#include "spi.h"
#include "usart.h"
#include "gpio.h"

int main(void)
{
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init();
    MX_I2C1_Init();
    MX_SPI3_Init();
    MX_USART1_UART_Init();
    MX_USART6_UART_Init();
    while (1) {
    }
}