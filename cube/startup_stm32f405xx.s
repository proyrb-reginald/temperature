.syntax unified /* 指定汇编语法为统一格式 */
.cpu cortex-m4 /* 指定目标CPU为Cortex-M4 */
.fpu softvfp  /* 指定FPU为软件仿真 */
.thumb   /* 指定使用Thumb指令集 */

.global g_pfnVectors  /* 声明全局符号g_pfnVectors，这是中断向量表的起始地址 */
.global Default_Handler /* 声明全局符号Default_Handler，这是默认中断处理函数 */

.word _sidata /* 定义.data段初始化数据在Flash中的起始地址 */
.word _sdata /* 定义.data段在SRAM中的起始地址 */
.word _edata /* 定义.data段在SRAM中的结束地址 */
.word _sbss  /* 定义.bss段在SRAM中的起始地址 */
.word _ebss  /* 定义.bss段在SRAM中的结束地址 */


.section .text.Reset_Handler  /* 定义.text.Reset_Handler段 */
.weak Reset_Handler   /* 定义弱符号Reset_Handler，允许用户重定义 */
.type Reset_Handler, %function /* 定义Reset_Handler为函数类型 */
Reset_Handler:
 /* 从链接脚本定义的_estack符号加载值到SP寄存器，设置主堆栈指针 */
 ldr sp, =_estack 
 /* 调用时钟系统初始化函数，配置系统时钟 */
 bl SystemInit 
 /* 将.data段的初始化数据从Flash复制到SRAM */
 /* 加载.data段在SRAM中的起始地址到r0寄存器 */
 ldr r0, =_sdata
 /* 加载.data段在SRAM中的结束地址到r1寄存器 */
 ldr r1, =_edata
 /* 加载.data段初始化数据在Flash中的起始地址到r2寄存器 */
 ldr r2, =_sidata
 /* 将r3寄存器清零，用作偏移量 */
 movs r3, #0
 /* 跳转到循环复制数据的标签 */
 b LoopCopyDataInit

/* 数据复制循环体：将一个字（4字节）从Flash复制到SRAM */
CopyDataInit:
 /* 从Flash地址(r2+r3)读取一个字到r4寄存器 */
 ldr r4, [r2, r3]
 /* 将r4寄存器的值写入SRAM地址(r0+r3) */
 str r4, [r0, r3]
 /* 增加偏移量r3，步长为4字节 */
 adds r3, r3, #4

/* 循环复制数据的条件判断 */
LoopCopyDataInit:
 /* 计算当前SRAM写入地址(r0+r3) */
 adds r4, r0, r3
 /* 比较当前写入地址与.data段结束地址 */
 cmp r4, r1
 /* 如果当前地址小于结束地址，则继续复制 */
 bcc CopyDataInit
 /* 对.bss段进行零填充初始化 */
 /* 加载.bss段在SRAM中的起始地址到r2寄存器 */
 ldr r2, =_sbss
 /* 加载.bss段在SRAM中的结束地址到r4寄存器 */
 ldr r4, =_ebss
 /* 将r3寄存器清零，用作写入的零值 */
 movs r3, #0
 /* 跳转到循环清零的标签 */
 b LoopFillZerobss

/* .bss段零填充循环体 */
FillZerobss:
 /* 将零值写入.bss段当前地址 */
 str r3, [r2]
 /* 增加.bss段地址指针，步长为4字节 */
 adds r2, r2, #4

/* 循环清零的条件判断 */
LoopFillZerobss:
 /* 比较当前.bss地址与结束地址 */
 cmp r2, r4
 /* 如果当前地址小于结束地址，则继续清零 */
 bcc FillZerobss
 /* 调用C库静态构造函数初始化 */
 bl __libc_init_array
 /* 调用应用程序的入口点main函数 */
 bl main
 /* 返回到调用者（理论上不会执行到这里） */
 bx lr  
 /* 定义Reset_Handler函数的大小 */
 .size Reset_Handler, .-Reset_Handler

/* 定义.text.Default_Handler段，属性为可执行 */
.section .text.Default_Handler, "ax", %progbits
/* 定义默认中断处理函数 */
Default_Handler:
/* 无限循环标签 */
Infinite_Loop:
 /* 无条件跳转到自身，形成无限循环 */
 b Infinite_Loop
 /* 定义Default_Handler函数的大小 */
 .size Default_Handler, .-Default_Handler

/* 定义.isr_vector段，属性为分配、可读 */
.section .isr_vector, "a", %progbits
/* 定义g_pfnVectors为对象类型 */
.type g_pfnVectors, %object
  
/* 定义中断向量表的起始地址g_pfnVectors */
g_pfnVectors:
  /* 第一个条目：主堆栈指针初始值 */
  .word _estack
  /* 第二个条目：复位处理函数地址 */
  .word Reset_Handler

  /* 以下为Cortex-M4内核异常处理函数地址 */
  .word NMI_Handler /* 非屏蔽中断处理函数 */
  .word HardFault_Handler /* 硬件故障中断处理函数 */
  .word MemManage_Handler /* 存储器管理故障中断处理函数 */
  .word BusFault_Handler  /* 总线故障中断处理函数 */
  .word UsageFault_Handler  /* 用法故障中断处理函数 */
  .word 0 /* 保留 */
  .word 0 /* 保留 */
  .word 0 /* 保留 */
  .word 0 /* 保留 */
  .word SVC_Handler /* 系统服务调用中断处理函数 */
  .word DebugMon_Handler  /* 调试监控中断处理函数 */
  .word 0 /* 保留 */
  .word PendSV_Handler  /* PendSV中断处理函数 */
  .word SysTick_Handler /* 系统滴答定时器中断处理函数 */
 
  /* 外部设备中断向量表 */
  .word WWDG_IRQHandler /* 窗口看门狗中断 */        
  .word PVD_IRQHandler  /* 可编程电压检测通过EXTI线的中断 */    
  .word TAMP_STAMP_IRQHandler /* 防篡改和时间戳通过EXTI线的中断 */  
  .word RTC_WKUP_IRQHandler /* RTC唤醒通过EXTI线的中断 */     
  .word FLASH_IRQHandler  /* Flash存储器中断 */       
  .word RCC_IRQHandler  /* 复位和时钟控制器中断 */        
  .word EXTI0_IRQHandler  /* 外部中断线0 */    
  .word EXTI1_IRQHandler  /* 外部中断线1 */     
  .word EXTI2_IRQHandler  /* 外部中断线2 */     
  .word EXTI3_IRQHandler  /* 外部中断线3 */     
  .word EXTI4_IRQHandler  /* 外部中断线4 */     
  .word DMA1_Stream0_IRQHandler /* DMA1流0中断 */   
  .word DMA1_Stream1_IRQHandler /* DMA1流1中断 */    
  .word DMA1_Stream2_IRQHandler /* DMA1流2中断 */    
  .word DMA1_Stream3_IRQHandler /* DMA1流3中断 */    
  .word DMA1_Stream4_IRQHandler /* DMA1流4中断 */    
  .word DMA1_Stream5_IRQHandler /* DMA1流5中断 */    
  .word DMA1_Stream6_IRQHandler /* DMA1流6中断 */    
  .word ADC_IRQHandler  /* ADC1, ADC2和ADC3中断 */    
  .word CAN1_TX_IRQHandler  /* CAN1发送中断 */     
  .word CAN1_RX0_IRQHandler /* CAN1接收0中断 */     
  .word CAN1_RX1_IRQHandler /* CAN1接收1中断 */     
  .word CAN1_SCE_IRQHandler /* CAN1错误状态中断 */     
  .word EXTI9_5_IRQHandler  /* 外部中断线[9:5] */     
  .word TIM1_BRK_TIM9_IRQHandler  /* TIM1刹车和TIM9中断 */   
  .word TIM1_UP_TIM10_IRQHandler  /* TIM1更新和TIM10中断 */   
  .word TIM1_TRG_COM_TIM11_IRQHandler /* TIM1触发和通信及TIM11中断 */
  .word TIM1_CC_IRQHandler  /* TIM1捕获比较中断 */     
  .word TIM2_IRQHandler /* TIM2中断 */    
  .word TIM3_IRQHandler /* TIM3中断 */    
  .word TIM4_IRQHandler /* TIM4中断 */    
  .word I2C1_EV_IRQHandler  /* I2C1事件中断 */     
  .word I2C1_ER_IRQHandler  /* I2C1错误中断 */     
  .word I2C2_EV_IRQHandler  /* I2C2事件中断 */     
  .word I2C2_ER_IRQHandler  /* I2C2错误中断 */      
  .word SPI1_IRQHandler /* SPI1中断 */    
  .word SPI2_IRQHandler /* SPI2中断 */    
  .word USART1_IRQHandler /* USART1中断 */    
  .word USART2_IRQHandler   /* USART2中断 */    
  .word USART3_IRQHandler   /* USART3中断 */    
  .word EXTI15_10_IRQHandler   /* 外部中断线[15:10] */     
  .word RTC_Alarm_IRQHandler   /* RTC报警(A和B)通过EXTI线中断 */   
  .word OTG_FS_WKUP_IRQHandler  /* USB OTG FS唤醒通过EXTI线中断 */    
  .word TIM8_BRK_TIM12_IRQHandler   /* TIM8刹车和TIM12中断 */   
  .word TIM8_UP_TIM13_IRQHandler   /* TIM8更新和TIM13中断 */   
  .word TIM8_TRG_COM_TIM14_IRQHandler /* TIM8触发和通信及TIM14中断 */
  .word TIM8_CC_IRQHandler    /* TIM8捕获比较中断 */     
  .word DMA1_Stream7_IRQHandler  /* DMA1流7中断 */     
  .word FSMC_IRQHandler    /* FSMC中断 */    
  .word SDIO_IRQHandler    /* SDIO中断 */    
  .word TIM5_IRQHandler    /* TIM5中断 */    
  .word SPI3_IRQHandler    /* SPI3中断 */    
  .word UART4_IRQHandler   /* UART4中断 */    
  .word UART5_IRQHandler   /* UART5中断 */    
  .word TIM6_DAC_IRQHandler    /* TIM6和DAC1&2下溢错误中断 */    
  .word TIM7_IRQHandler    /* TIM7中断 */
  .word DMA2_Stream0_IRQHandler  /* DMA2流0中断 */    
  .word DMA2_Stream1_IRQHandler  /* DMA2流1中断 */    
  .word DMA2_Stream2_IRQHandler  /* DMA2流2中断 */    
  .word DMA2_Stream3_IRQHandler  /* DMA2流3中断 */    
  .word DMA2_Stream4_IRQHandler  /* DMA2流4中断 */    
  .word 0       /* 保留 */    
  .word 0       /* 保留 */     
  .word CAN2_TX_IRQHandler    /* CAN2发送中断 */     
  .word CAN2_RX0_IRQHandler    /* CAN2接收0中断 */     
  .word CAN2_RX1_IRQHandler    /* CAN2接收1中断 */     
  .word CAN2_SCE_IRQHandler    /* CAN2错误状态中断 */     
  .word OTG_FS_IRQHandler   /* USB OTG FS中断 */    
  .word DMA2_Stream5_IRQHandler  /* DMA2流5中断 */    
  .word DMA2_Stream6_IRQHandler  /* DMA2流6中断 */    
  .word DMA2_Stream7_IRQHandler  /* DMA2流7中断 */    
  .word USART6_IRQHandler   /* USART6中断 */    
  .word I2C3_EV_IRQHandler    /* I2C3事件中断 */     
  .word I2C3_ER_IRQHandler    /* I2C3错误中断 */     
  .word OTG_HS_EP1_OUT_IRQHandler   /* USB OTG HS端点1输出中断 */    
  .word OTG_HS_EP1_IN_IRQHandler   /* USB OTG HS端点1输入中断 */    
  .word OTG_HS_WKUP_IRQHandler  /* USB OTG HS唤醒通过EXTI中断 */     
  .word OTG_HS_IRQHandler   /* USB OTG HS中断 */    
  .word 0       /* 保留 */    
  .word 0       /* 保留 */    
  .word HASH_RNG_IRQHandler    /* 哈希和随机数生成器中断 */
  .word FPU_IRQHandler    /* 浮点运算单元中断 */

  /* 定义向量表g_pfnVectors的大小 */
  .size g_pfnVectors, .-g_pfnVectors

  /* 为NMI_Handler提供弱别名，使其默认指向Default_Handler */
  .weak NMI_Handler
  .thumb_set NMI_Handler,Default_Handler
 
  /* 为HardFault_Handler提供弱别名 */
  .weak HardFault_Handler
  .thumb_set HardFault_Handler,Default_Handler
 
  /* 为MemManage_Handler提供弱别名 */
  .weak MemManage_Handler
  .thumb_set MemManage_Handler,Default_Handler
 
  /* 为BusFault_Handler提供弱别名 */
  .weak BusFault_Handler
  .thumb_set BusFault_Handler,Default_Handler

  /* 为UsageFault_Handler提供弱别名 */
  .weak UsageFault_Handler
  .thumb_set UsageFault_Handler,Default_Handler

  /* 为SVC_Handler提供弱别名 */
  .weak SVC_Handler
  .thumb_set SVC_Handler,Default_Handler

  /* 为DebugMon_Handler提供弱别名 */
  .weak DebugMon_Handler
  .thumb_set DebugMon_Handler,Default_Handler

  /* 为PendSV_Handler提供弱别名 */
  .weak PendSV_Handler
  .thumb_set PendSV_Handler,Default_Handler

  /* 为SysTick_Handler提供弱别名 */
  .weak SysTick_Handler
  .thumb_set SysTick_Handler,Default_Handler   
 
  /* 为外部中断提供弱别名，使它们默认指向Default_Handler */
  .weak WWDG_IRQHandler    
  .thumb_set WWDG_IRQHandler,Default_Handler 
   
  .weak PVD_IRQHandler 
  .thumb_set PVD_IRQHandler,Default_Handler
    
  .weak TAMP_STAMP_IRQHandler  
  .thumb_set TAMP_STAMP_IRQHandler,Default_Handler
  
  .weak RTC_WKUP_IRQHandler   
  .thumb_set RTC_WKUP_IRQHandler,Default_Handler
  
  .weak FLASH_IRQHandler   
  .thumb_set FLASH_IRQHandler,Default_Handler
   
  .weak RCC_IRQHandler 
  .thumb_set RCC_IRQHandler,Default_Handler
   
  .weak EXTI0_IRQHandler   
  .thumb_set EXTI0_IRQHandler,Default_Handler
   
  .weak EXTI1_IRQHandler   
  .thumb_set EXTI1_IRQHandler,Default_Handler
     
  .weak EXTI2_IRQHandler   
  .thumb_set EXTI2_IRQHandler,Default_Handler 
   
  .weak EXTI3_IRQHandler   
  .thumb_set EXTI3_IRQHandler,Default_Handler
    
  .weak EXTI4_IRQHandler   
  .thumb_set EXTI4_IRQHandler,Default_Handler
   
  .weak DMA1_Stream0_IRQHandler    
  .thumb_set DMA1_Stream0_IRQHandler,Default_Handler
   
  .weak DMA1_Stream1_IRQHandler    
  .thumb_set DMA1_Stream1_IRQHandler,Default_Handler
   
  .weak DMA1_Stream2_IRQHandler    
  .thumb_set DMA1_Stream2_IRQHandler,Default_Handler
   
  .weak DMA1_Stream3_IRQHandler    
  .thumb_set DMA1_Stream3_IRQHandler,Default_Handler 
   
  .weak DMA1_Stream4_IRQHandler   
  .thumb_set DMA1_Stream4_IRQHandler,Default_Handler
   
  .weak DMA1_Stream5_IRQHandler    
  .thumb_set DMA1_Stream5_IRQHandler,Default_Handler
   
  .weak DMA1_Stream6_IRQHandler    
  .thumb_set DMA1_Stream6_IRQHandler,Default_Handler
   
  .weak ADC_IRQHandler 
  .thumb_set ADC_IRQHandler,Default_Handler
    
  .weak CAN1_TX_IRQHandler  
  .thumb_set CAN1_TX_IRQHandler,Default_Handler
  
  .weak CAN1_RX0_IRQHandler   
  .thumb_set CAN1_RX0_IRQHandler,Default_Handler
      
  .weak CAN1_RX1_IRQHandler   
  .thumb_set CAN1_RX1_IRQHandler,Default_Handler
  
  .weak CAN1_SCE_IRQHandler   
  .thumb_set CAN1_SCE_IRQHandler,Default_Handler
  
  .weak EXTI9_5_IRQHandler  
  .thumb_set EXTI9_5_IRQHandler,Default_Handler
  
  .weak TIM1_BRK_TIM9_IRQHandler  
  .thumb_set TIM1_BRK_TIM9_IRQHandler,Default_Handler
  
  .weak TIM1_UP_TIM10_IRQHandler  
  .thumb_set TIM1_UP_TIM10_IRQHandler,Default_Handler
 
  .weak TIM1_TRG_COM_TIM11_IRQHandler 
  .thumb_set TIM1_TRG_COM_TIM11_IRQHandler,Default_Handler
 
  .weak TIM1_CC_IRQHandler  
  .thumb_set TIM1_CC_IRQHandler,Default_Handler
   
  .weak TIM2_IRQHandler  
  .thumb_set TIM2_IRQHandler,Default_Handler
   
  .weak TIM3_IRQHandler  
  .thumb_set TIM3_IRQHandler,Default_Handler
   
  .weak TIM4_IRQHandler  
  .thumb_set TIM4_IRQHandler,Default_Handler
   
  .weak I2C1_EV_IRQHandler  
  .thumb_set I2C1_EV_IRQHandler,Default_Handler
     
  .weak I2C1_ER_IRQHandler  
  .thumb_set I2C1_ER_IRQHandler,Default_Handler
     
  .weak I2C2_EV_IRQHandler  
  .thumb_set I2C2_EV_IRQHandler,Default_Handler
   
  .weak I2C2_ER_IRQHandler  
  .thumb_set I2C2_ER_IRQHandler,Default_Handler
      
  .weak SPI1_IRQHandler  
  .thumb_set SPI1_IRQHandler,Default_Handler
    
  .weak SPI2_IRQHandler  
  .thumb_set SPI2_IRQHandler,Default_Handler
   
  .weak USART1_IRQHandler 
  .thumb_set USART1_IRQHandler,Default_Handler
     
  .weak USART2_IRQHandler 
  .thumb_set USART2_IRQHandler,Default_Handler
     
  .weak USART3_IRQHandler 
  .thumb_set USART3_IRQHandler,Default_Handler
   
  .weak EXTI15_10_IRQHandler    
  .thumb_set EXTI15_10_IRQHandler,Default_Handler
    
  .weak RTC_Alarm_IRQHandler    
  .thumb_set RTC_Alarm_IRQHandler,Default_Handler
  
  .weak OTG_FS_WKUP_IRQHandler   
  .thumb_set OTG_FS_WKUP_IRQHandler,Default_Handler
  
  .weak TIM8_BRK_TIM12_IRQHandler   
  .thumb_set TIM8_BRK_TIM12_IRQHandler,Default_Handler
   
  .weak TIM8_UP_TIM13_IRQHandler  
  .thumb_set TIM8_UP_TIM13_IRQHandler,Default_Handler
   
  .weak TIM8_TRG_COM_TIM14_IRQHandler 
  .thumb_set TIM8_TRG_COM_TIM14_IRQHandler,Default_Handler
 
  .weak TIM8_CC_IRQHandler  
  .thumb_set TIM8_CC_IRQHandler,Default_Handler
   
  .weak DMA1_Stream7_IRQHandler    
  .thumb_set DMA1_Stream7_IRQHandler,Default_Handler
     
  .weak FSMC_IRQHandler  
  .thumb_set FSMC_IRQHandler,Default_Handler
     
  .weak SDIO_IRQHandler  
  .thumb_set SDIO_IRQHandler,Default_Handler
     
  .weak TIM5_IRQHandler  
  .thumb_set TIM5_IRQHandler,Default_Handler
     
  .weak SPI3_IRQHandler  
  .thumb_set SPI3_IRQHandler,Default_Handler
     
  .weak UART4_IRQHandler   
  .thumb_set UART4_IRQHandler,Default_Handler
   
  .weak UART5_IRQHandler   
  .thumb_set UART5_IRQHandler,Default_Handler
   
  .weak TIM6_DAC_IRQHandler   
  .thumb_set TIM6_DAC_IRQHandler,Default_Handler
    
  .weak TIM7_IRQHandler  
  .thumb_set TIM7_IRQHandler,Default_Handler
   
  .weak DMA2_Stream0_IRQHandler    
  .thumb_set DMA2_Stream0_IRQHandler,Default_Handler
    
  .weak DMA2_Stream1_IRQHandler    
  .thumb_set DMA2_Stream1_IRQHandler,Default_Handler
   
  .weak DMA2_Stream2_IRQHandler    
  .thumb_set DMA2_Stream2_IRQHandler,Default_Handler
  
  .weak DMA2_Stream3_IRQHandler    
  .thumb_set DMA2_Stream3_IRQHandler,Default_Handler
  
  .weak DMA2_Stream4_IRQHandler    
  .thumb_set DMA2_Stream4_IRQHandler,Default_Handler
  
  .weak CAN2_TX_IRQHandler  
  .thumb_set CAN2_TX_IRQHandler,Default_Handler
      
  .weak CAN2_RX0_IRQHandler   
  .thumb_set CAN2_RX0_IRQHandler,Default_Handler
      
  .weak CAN2_RX1_IRQHandler   
  .thumb_set CAN2_RX1_IRQHandler,Default_Handler
      
  .weak CAN2_SCE_IRQHandler   
  .thumb_set CAN2_SCE_IRQHandler,Default_Handler
      
  .weak OTG_FS_IRQHandler 
  .thumb_set OTG_FS_IRQHandler,Default_Handler
     
  .weak DMA2_Stream5_IRQHandler    
  .thumb_set DMA2_Stream5_IRQHandler,Default_Handler
   
  .weak DMA2_Stream6_IRQHandler    
  .thumb_set DMA2_Stream6_IRQHandler,Default_Handler
   
  .weak DMA2_Stream7_IRQHandler    
  .thumb_set DMA2_Stream7_IRQHandler,Default_Handler
   
  .weak USART6_IRQHandler 
  .thumb_set USART6_IRQHandler,Default_Handler
    
  .weak I2C3_EV_IRQHandler  
  .thumb_set I2C3_EV_IRQHandler,Default_Handler
    
  .weak I2C3_ER_IRQHandler  
  .thumb_set I2C3_ER_IRQHandler,Default_Handler
    
  .weak OTG_HS_EP1_OUT_IRQHandler   
  .thumb_set OTG_HS_EP1_OUT_IRQHandler,Default_Handler
    
  .weak OTG_HS_EP1_IN_IRQHandler  
  .thumb_set OTG_HS_EP1_IN_IRQHandler,Default_Handler
    
  .weak OTG_HS_WKUP_IRQHandler   
  .thumb_set OTG_HS_WKUP_IRQHandler,Default_Handler
  
  .weak OTG_HS_IRQHandler 
  .thumb_set OTG_HS_IRQHandler,Default_Handler
         
  .weak HASH_RNG_IRQHandler   
  .thumb_set HASH_RNG_IRQHandler,Default_Handler  

  .weak FPU_IRQHandler   
  .thumb_set FPU_IRQHandler,Default_Handler 