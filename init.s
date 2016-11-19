#-------------------------------------------------
#
# Код инициализации и мультизагрузки
#    
#-----------------------------------------------*/
.code32

#-------------------------------------------------
#    Константы для заголовка Multiboot
#-----------------------------------------------*/
.set MBOOT_HEADER_MAGIC, 0x1BADB002
.set MBOOT_HEADER_FLAGS, 0x00000001
.set MBOOT_CHECKSUM, -(MBOOT_HEADER_MAGIC+MBOOT_HEADER_FLAGS)

# Указываем что функция main - внешняя и расположена в другом
# объектном модуле */ 
.extern main

# Секция - заголовок мультизагрузки */
.section .mboot

.int MBOOT_HEADER_MAGIC
.int MBOOT_HEADER_FLAGS
.int MBOOT_CHECKSUM
 
# Секция кода */
.section    .text

# Делаем точку входа глобальной, доступной для компоновщика */
.global      init

init:
        cli # Выключаем ВСЕ прерывания */
        
        push    %eax # Заталкиваем в стек */
        push    %ebx # регистры общего назначения */
        
        call    main # вызываем main */
        
        hlt # Останавливаем процессор */
        
loop: # Переходим в бесконечный цикл */
        jmp    loop