; LZSS Decoder - 65816

.65816

.org 018000
.base 8000

compressed_map_siz:     .db 097d
compressed_map:         .incbin assets/big.bin.lzss

.org 7e0000

EI:                     .rb 1
EJ:                     .rb 1
N:                      .rb 2
F:                      .rb 1

r:                      .rb 2
i:                      .rb 2
j:                      .rb 2
k:                      .rb 2

buf:                    .rb 1
mask:                   .rb 1

infile:                 .rb 3   ; address of file to decompress
infile_idx:             .rb 2   ; index to current infile byte
infile_siz:             .rb 2

buffer_addr:            .rb 3   ; address of buffer
outfile_addr:           .rb 3   ; address of outfile
outfile_idx:            .rb 2   ; index to current outfile byte

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

    jsr @LzssDecode

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

    ldy @infile_idx
    cpy @infile_siz
    bcc @continue_getbit_loop
    ldx #ffff           ; we return 0xffff (EOF) if infile_idx >= infile_siz
    ply
    bra @end_getbit

continue_getbit_loop:
    lda [<infile],y

    sta @buf
    lda #80
    sta @mask

    iny
    sty @infile_idx
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
    lda #20
    ldy @r
    iny
clear_buffer_loop:
    dey
    sta [<buffer_addr],y
    bne @clear_buffer_loop

decode_loop:
    ldy #0001
    jsr @GetBit         ; c = getbit(1)

    cpx #ffff
    beq @decode_done    ; if (c == EOF)

    cpx #0001
    beq @bit_is_one     ; if (c == 1)

    ; ---- c == 0
    lda @EI
    rep #20
    and #00ff
    tay
    sep #20
    jsr @GetBit
    cpx #ffff
    beq @decode_done
    stx @i

    lda @EJ
    rep #20
    and #00ff
    tay
    sep #20
    jsr @GetBit
    cpx #ffff
    beq @decode_done
    stx @j

    brk 00
    jsr @BufferLoop

    bra @decode_loop

bit_is_one:
    ; ---- c == 1
    ldy #0008
    jsr @GetBit
    cpx #ffff
    beq @decode_done

    txa
    ldy @outfile_idx
    sta [<outfile_addr],y

    ldy @r
    sta [<buffer_addr],y

    rep #20
    ; r = (r + 1) & (N - 1)
    inc @r
    lda @N
    dec
    and @r
    sta @r

    inc @outfile_idx
    sep #20

    bra @decode_loop

decode_done:
    rts


BufferLoop:
    inx
    inx
    stx @k
    ldy #0000
buffer_loop:
    phy

    rep #20
    tya
    clc
    adc @i
    pha
    lda @N
    dec
    and 01,s
    tay
    pla
    sep #20

    lda [<buffer_addr],y
    ldy @outfile_idx
    sta [<outfile_addr],y

    ldy @r
    sta [<buffer_addr],y

    rep #20
    ; r = (r + 1) & (N - 1)
    inc @r
    lda @N
    dec
    and @r
    sta @r

    inc @outfile_idx
    sep #20

    ply
    iny
    cpy @k

    bne @buffer_loop

    rts

.include init.asm
.include info.asm

