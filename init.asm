ClearRegisters:
    stz 2101
    stz 2102
    stz 2103
    stz 2105
    stz 2106
    stz 2107
    stz 2108
    stz 2109
    stz 210a
    stz 210b
    stz 210c

    rep #20

    stz 210d
    stz 210d
    stz 210e
    stz 210e
    stz 210f
    stz 210f
    stz 2110
    stz 2110
    stz 2111
    stz 2111
    stz 2112
    stz 2112
    stz 2113
    stz 2113
    stz 2114
    stz 2114

    sep #20

    lda #80
    sta 2115
    stz 2116
    stz 2117
    stz 211a

    rep #20

    lda #0001
    sta 211b
    stz 211c
    stz 211d
    sta 211e
    stz 211f
    stz 2120

    sep #20

    stz 2121
    stz 2123
    stz 2124
    stz 2125
    stz 2126
    stz 2127
    stz 2128
    stz 2129
    stz 212a
    stz 212b
    lda #01
    sta 212c
    stz 212d
    stz 212e
    stz 212f
    lda #30
    sta 2130
    stz 2131
    lda #e0
    sta 2132
    stz 2133

    stz 4200
    lda #ff
    sta 4201
    stz 4202
    stz 4203
    stz 4204
    stz 4205
    stz 4206
    stz 4207
    stz 4208
    stz 4209
    stz 420a
    stz 420b
    stz 420c
    lda #01
    sta 420d

    ; ---- custom registers

    stz @screen_tm_x
    stz @screen_tm_y
    stz @prev_screen_tm_x
    stz @prev_screen_tm_y
    stz @screen_x_velocity
    stz @screen_y_velocity
    rep #20
    stz @screen_m_x
    stz @screen_m_y
    stz @prev_screen_m_x
    stz @prev_screen_m_y
    sep #20

    rts
