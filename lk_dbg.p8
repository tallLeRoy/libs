%import emudbg
%import conv
%import floats

dbg {  ; print to emulator console
    %option ignore_unused

    sub console_write(uword petString) { ; use the PETSCII strings here to write to the console

        ; table to convert some PETSCII letters into ASCII
        ubyte[] ascii_table = [ 
        $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0A, $0E, $0F, 
        $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, 
        $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F, 
        $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, 
        $40, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, 
        $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $5B, $5C, $5D, $5E, $5F, 
        $60, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, 
        $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $7B, $7C, $7D, $7E, $7F, 
        $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F, 
        $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F, 
        $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF, 
        $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF, 
        $C0, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, 
        $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $DB, $DC, $DD, $DE, $DF, 
        $E0, $E1, $E2, $E3, $5F, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF, 
        $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $7E  ]

        if emudbg.is_emulator() {
            ubyte chr 
            repeat {
                chr = ascii_table[@(petString)]
                if chr == 0 {              ; string end
                    break
                }
                if chr == '\x0A' { ; new line
                    emudbg.EMU_CHROUT = '\x0D' ; carrier return for Windows
                }
                emudbg.EMU_CHROUT = chr
                petString++
            }
        }
    }

    sub optprint(uword s) { if s[0] != 0 console_write(s) }

    sub print_sb   (uword before,  byte value, uword after) { optprint(before) void conv.str_b(value) optprint(conv.string_out) optprint(after) }
    sub print_sub  (uword before, ubyte value, uword after) { optprint(before) void conv.str_ub(value) optprint(conv.string_out) optprint(after) }
    sub print_subhex  (uword before, ubyte value, uword after) { optprint(before) void conv.str_ubhex(value) optprint(conv.string_out) optprint(after) }
    sub print_sw   (uword before,  word value, uword after) { optprint(before) void conv.str_w(value) optprint(conv.string_out) optprint(after) }
    sub print_suw  (uword before, uword value, uword after) { optprint(before) void conv.str_uw(value) optprint(conv.string_out) optprint(after) }
    sub print_suwhex  (uword before, uword value, uword after) { optprint(before) void conv.str_uwhex(value) optprint(conv.string_out) optprint(after) }
    sub print_sf   (uword before, float value, uword after) { optprint(before) optprint(floats.tostr(value)) optprint(after) }
    sub print_sc   (uword before, ubyte value, uword after) { optprint(before) emudbg.EMU_CHROUT=value optprint(after) }

    sub print_b   (byte value)   { void conv.str_b(value) optprint(conv.string_out) }
    sub print_ub  (ubyte value)  { void conv.str_ub(value) optprint(conv.string_out) }
    sub print_ubhex (ubyte value)  { void conv.str_ubhex(value) optprint(conv.string_out) }
    sub print_w   (word value)   { void conv.str_w(value) optprint(conv.string_out) }
    sub print_uw  (uword value)  { void conv.str_uw(value)optprint(conv.string_out) }
    sub print_uwhex  (uword value)  { void conv.str_uwhex(value) optprint(conv.string_out) }
    sub print_f   (float value)  { optprint(floats.tostr(value)) }
    sub print     (uword value)  { optprint(value)}
    sub print_c   (ubyte value)  { emudbg.EMU_CHROUT=value}

    sub nl()  { optprint("\n") }
    sub spc() { optprint(" ") }

    sub stop() { %asm{{stp}} }

} ; end dbg block

; unused subroutines

/*  ; only need these next two subs to generate the above ascii_table
    sub ascii_chr(ubyte chr) -> ubyte {   ; PETSCII char in, ASCII char out 
        if chr in 65 to 90 { ; invert case lower -> upper
            chr += 32
        } else if chr in 97 to 122 {
            chr -= 32
        } else if chr in 193 to 218 {   ; invert case upper -> lower
            chr ^= $80
        } else if chr == '\n' {  ; new line  
            chr = '\x0A'
        } else if chr == 255 {  ; the tilde
            chr = 126    
        }
        return chr
    }

    sub make_a_table() {
        ubyte i, j, chr, digit 
        for i in 0 to 15 {
            for j in 0 to 15 {
                chr = ascii_chr(i*16+j)
                conv.str_ubhex(chr)
                uword num = conv.string_out as uword
                emudbg.EMU_CHROUT = '$'
                repeat 2 {
                    digit = @(num)
                    emudbg.EMU_CHROUT = digit
                    num++
                }
                emudbg.EMU_CHROUT = ','
                emudbg.EMU_CHROUT = ' '
            }
            emudbg.EMU_CHROUT = '\x0A'   ; newline
        }
    }
*/

