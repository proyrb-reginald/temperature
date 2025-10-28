/* 定义程序入口点 */
ENTRY(Reset_Handler)

/* 定义内存区域 */
MEMORY
{
  /* 主SRAM：起始地址0x20000000，大小128KB，支持读写执行 */
  RAM(xrw)    : ORIGIN = 0x20000000, LENGTH = 128K
  /* CCMRAM：起始地址0x10000000，大小64KB，支持读写执行，零等待周期访问 */
  CCMRAM(xrw) : ORIGIN = 0x10000000, LENGTH = 64K
  /* Flash：起始地址0x08000000，大小1024KB，支持读取和执行 */
  FLASH(rx)   : ORIGIN = 0x08000000, LENGTH = 1024K
}

/* 定义栈顶地址：RAM的结束地址 */
_estack = ORIGIN(RAM) + LENGTH(RAM);
/* 定义最小堆大小：512字节 */
_Min_Heap_Size = 0x200;
/* 定义最小栈大小：1024字节 */
_Min_Stack_Size = 0x400;

/* 定义输出段 */
SECTIONS
{
  /* 中断向量表段：放置在Flash起始位置 */
  .isr_vector : ALIGN(4)
  {
    KEEP(*(.isr_vector))       /* 保留中断向量表，防止被优化掉 */
  } > FLASH

  /* 代码段：包含程序代码和只读数据 */
  .text : ALIGN(4)
  {
    *(.text)                  /* 普通代码段 */
    *(.text*)                 /* 其他代码段 */
    *(.glue_7)                /* ARM和Thumb模式切换胶合代码 */
    *(.glue_7t)               /* Thumb到ARM模式切换胶合代码 */
    *(.eh_frame)              /* 异常处理框架 */

    KEEP(*(.init))            /* 初始化代码 */
    KEEP(*(.fini))            /* 结束代码 */

    . = ALIGN(4);
    _etext = .;               /* 代码段结束标志 */
  } > FLASH

  /* 只读数据段：常量、字符串等 */
  .rodata : ALIGN(4)
  {
    *(.rodata)                /* 只读数据段 */
    *(.rodata*)               /* 其他只读数据段 */
  } > FLASH

  /* ARM异常展开表：用于C++异常处理和栈回溯 */
  .ARM.extab(READONLY) : ALIGN(4)
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*)
  } > FLASH

  /* ARM异常索引表 */
  .ARM(READONLY) : ALIGN(4)
  {
    __exidx_start = .;        /* 异常索引表起始地址 */
    *(.ARM.exidx*)            /* 异常索引数据 */
    __exidx_end = .;          /* 异常索引表结束地址 */
  } > FLASH

  /* 预初始化数组：程序启动前的初始化函数 */
  .preinit_array(READONLY) : ALIGN(4)
  {
    PROVIDE_HIDDEN(__preinit_array_start = .);  /* 预初始化数组起始地址 */
    KEEP(*(.preinit_array*))                    /* 保留预初始化函数 */
    PROVIDE_HIDDEN(__preinit_array_end = .);    /* 预初始化数组结束地址 */
  } > FLASH

  /* 初始化数组：构造函数等初始化代码 */
  .init_array(READONLY) : ALIGN(4)
  {
    PROVIDE_HIDDEN(__init_array_start = .);     /* 初始化数组起始地址 */
    KEEP(*(SORT(.init_array.*)))                /* 按名称排序的初始化函数 */
    KEEP(*(.init_array*))                       /* 其他初始化函数 */
    PROVIDE_HIDDEN(__init_array_end = .);       /* 初始化数组结束地址 */
  } > FLASH

  /* 结束数组：析构函数等清理代码 */
  .fini_array(READONLY) : ALIGN(4)
  {
    PROVIDE_HIDDEN(__fini_array_start = .);     /* 结束数组起始地址 */
    KEEP(*(SORT(.fini_array.*)))                /* 按名称排序的结束函数 */
    KEEP(*(.fini_array*))                       /* 其他结束函数 */
    PROVIDE_HIDDEN(__fini_array_end = .);       /* 结束数组结束地址 */
  } > FLASH

  /* CCMRAM段：紧密耦合内存，用于需要高速访问的数据 */
  _siccmram = LOADADDR(.ccmram);                 /* CCMRAM加载地址 */

  .ccmram :  ALIGN(4)
  {
    _sccmram = .;                                /* CCMRAM起始地址符号 */
    *(.ccmram)
    *(.ccmram*)
    . = ALIGN(4);
    _eccmram = .;                                /* CCMRAM结束地址符号 */
  } > CCMRAM AT > FLASH                          /* 运行在CCMRAM，加载到Flash */

  /* 数据段：已初始化的全局和静态变量 */
  _sidata = LOADADDR(.data);                     /* .data段在Flash中的加载地址 */

  .data : ALIGN(4)
  {
    _sdata = .;                                  /* .data段起始地址 */
    *(.data)                                     /* 已初始化的全局变量 */
    *(.data*)                                    /* 其他已初始化数据 */
    *(.RamFunc)                                  /* 需要运行在RAM中的函数 */
    *(.RamFunc*)                                 /* 其他RAM函数 */
  } > RAM AT > FLASH                             /* 运行在RAM，加载到Flash */

  /* 线程局部存储数据段：线程特定数据 */
  .tdata : ALIGN(4)
  {
    *(.tdata .tdata.* .gnu.linkonce.td.*)        /* 线程局部数据 */
    . = ALIGN(4);
    _edata = .;                                  /* 数据段结束地址 */
    PROVIDE(__data_end = .);
    PROVIDE(__tdata_end = .);
  } > RAM AT > FLASH

  /* 提供线程局部存储相关符号 */
  PROVIDE(__tdata_start = ADDR(.tdata));
  PROVIDE(__tdata_size = __tdata_end - __tdata_start);
  PROVIDE(__data_start = ADDR(.data));
  PROVIDE(__data_size = __data_end - __data_start);
  PROVIDE(__tdata_source = LOADADDR(.tdata));
  PROVIDE(__tdata_source_end = LOADADDR(.tdata) + SIZEOF(.tdata));
  PROVIDE(__tdata_source_size = __tdata_source_end - __tdata_source);
  PROVIDE(__data_source = LOADADDR(.data));
  PROVIDE(__data_source_end = __tdata_source_end);
  PROVIDE(__data_source_size = __data_source_end - __data_source);

  /* 线程局部存储未初始化数据段 */
  .tbss(NOLOAD) : ALIGN(4)
  {
    _sbss = .;                                   /* BSS段起始地址 */
    __bss_start__ = _sbss;
    *(.tbss .tbss.*)                             /* 线程局部未初始化数据 */
    . = ALIGN(4);
    PROVIDE(__tbss_end = .);
  } > RAM

  /* 提供线程局部存储BSS相关符号 */
  PROVIDE(__tbss_start = ADDR(.tbss));
  PROVIDE(__tbss_size = __tbss_end - __tbss_start);
  PROVIDE(__tbss_offset = ADDR(.tbss) - ADDR(.tdata));
  PROVIDE(__tls_base = __tdata_start);
  PROVIDE(__tls_end = __tbss_end);
  PROVIDE(__tls_size = __tls_end - __tls_base);
  PROVIDE(__tls_align = MAX(ALIGNOF(.tdata), ALIGNOF(.tbss)));
  PROVIDE(__tls_size_align =(__tls_size + __tls_align - 1) & ~(__tls_align - 1));
  PROVIDE(__arm32_tls_tcb_offset = MAX(8, __tls_align));
  PROVIDE(__arm64_tls_tcb_offset = MAX(16, __tls_align));

  /* BSS段：未初始化的全局和静态变量 */
  .bss(NOLOAD) : ALIGN(4)
  {
    *(.bss)                                      /* 未初始化的全局变量 */
    *(.bss*)                                     /* 其他未初始化数据 */
    *(COMMON)                                    /* 公共块 */
    . = ALIGN(4);
    _ebss = .;                                   /* BSS段结束地址 */
    __bss_end__ = _ebss;
    PROVIDE(__bss_end = .);
  } > RAM

  PROVIDE(__non_tls_bss_start = ADDR(.bss));
  PROVIDE(__bss_start = __tbss_start);
  PROVIDE(__bss_size = __bss_end - __bss_start);

  /* 用户堆栈段：用于检查RAM是否充足 */
  ._user_heap_stack(NOLOAD) : ALIGN(8)
  {
    PROVIDE(end = .);                            /* 堆栈起始地址 */
    PROVIDE(_end = .);
    . = . + _Min_Heap_Size;                      /* 分配堆空间 */
    . = . + _Min_Stack_Size;                     /* 分配栈空间 */
  } > RAM

  /* 丢弃标准库中的冗余信息 */
  /DISCARD/ :
  {
    libc.a:*(*)                               /* C库中的冗余段 */
    libm.a:*(*)                               /* 数学库中的冗余段 */
    libgcc.a:*(*)                             /* GCC运行时库中的冗余段 */
  }
}