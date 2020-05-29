; LZSS Decoder - 65816

.65816

.org 018000
.base 8000

compressed_map:         .incbin assets/big.bin.lzss

.org 7e0000

EI:                     .rb 1
EJ:                     .rb 1
N:                      .rb 2
F:                      .rb 1

buf:                    .rb 1
mask:                   .rb 1

infile:                 .rb 3   ; address of file to decompress
infile_ptr:             .rb 2   ; index to current infile byte
infile_siz:             .rb 2
outfile_ptr:            .rb 2   ; index to current outfile byte

.org 7e2000

buffer:                 .rb 1000
outfile:                .rb 4000

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

    brk 00
    ldy #000c
    jsr @GetBit

    ldy #000c
    jsr @GetBit

    ldy #000c
    jsr @GetBit

    ldy #000c
    jsr @GetBit

    jmp @MainLoop       ; loop forever

BreakVector:
    rti

NmiVector:
    lda 4210            ; RDNMI
    rti

MainLoop:
    jmp @MainLoop

; get n bits from infile
; n in Y
; result in X
GetBit:
    ldx #0000

getbit_loop:
    lda @mask
    bne @skip_fgetc

    phy

    ldy @infile_ptr
    cpy @infile_siz
    bcc @continue_getbit_loop
ldx #ffff                        ; we return 0xffff (EOF) if infile_ptr >= infile_siz
    ply
    bra @end_getbit

continue_getbit_loop:
    lda [<infile],y

    sta @buf
    lda #80
    sta @mask

    iny
    sty @infile_ptr
    ply

skip_fgetc:
    rep #20
    txa
    asl
    tax
    sep #20

    lda @mask
    and @buf
    beq @skip_inx

    inx

skip_inx:
    lsr @mask

    dey
    bne @getbit_loop

end_getbit:
    rts

LzssDecode:
    rts

.include init.asm
.include info.asm

