; LZSS Decoder - 65816

.65816

.org 018000
.base 8000

compressed_map:         .incbin big.bin.lzss

.org 7e2000

decompression_buffer: .rb 4000

.org 8000
.base 0000

ResetVector:
    sei                 ; disable interrupts
    clc
    xce
    sep #20             ; M8
    rep #10             ; X16

    ldx #1fff
    txs                 ; set stack pointer to 1fff

    ; Forced Blank
    lda #80
    sta 2100            ; INIDISP
    jsr @ClearRegisters

    stz 212c            ; disable background
    stz 2121            ; set CGRAM write address to 0 (first color)
    lda #ab             ; load color code
    sta 2122            ; write color to first palette entry
    stz 2122            ; write twice

    lda #0f             ; release forced blanking, set screen to full brightness
    sta 2100            ; INIDISP

    lda #80             ; enable NMI
    sta 4200            ; NMITIMEN
    cli                 ; enable interrupts

    jmp @LzssDecode

    jmp @MainLoop       ; loop forever

BrkVector:
    rti

NmiVector:
    lda 4210            ; RDNMI
    rti

MainLoop:
    jmp @MainLoop

LzssDecode:
    rts

.include init.asm
.include info.asm

