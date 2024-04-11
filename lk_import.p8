; lk_import.p8
; a collection of support subroutines
%import string
%import textio
%import syslib
%import math
%import floats
%import conv
%import lk_mem
%import lk_math32_816
%import lk_dbg

lk {  ; misc subroutines
    %option ignore_unused

    inline asmsub set_random_seeds() {
        %asm {{
            jsr cx16.entropy_get
            ; AY already contains the first seed
            stx cx16.r0L         ; R0 for the second seed    
            sty cx16.r0H
            jsr math.rndseed
        }}
    }

    sub emulate_VIC20 () {
        cx16.VERA_DC_BORDER = $ab
        txt.color2(6,1)
        void cx16.set_screen_mode($07)
        cx16.VERA_DC_HSCALE = 48
        cx16.VERA_CTRL = 2
        cx16.VERA_DC_VIDEO = 22
        cx16.VERA_DC_HSTOP = 139
        cx16.VERA_DC_VSTOP = 211
        cx16.VERA_CTRL = 0
        cx16.screen_set_charset(4, 0)
        sys.disable_caseswitch()
    }

    sub emulate_teletype () {
        txt.color2(0,1)
;        txt.clear_screen()
        void cx16.set_screen_mode(8)
;        cx16.VERA_CTRL = 0
;        cx16.VERA_DC_HSCALE = 128
        cx16.VERA_DC_BORDER = 1
;        cx16.VERA_CTRL = 2
;        cx16.VERA_DC_VIDEO = $11
;        cx16.VERA_DC_HSTART = 8
;        cx16.VERA_DC_HSTOP = 152
;        cx16.VERA_CTRL = 0
        cx16.screen_set_charset(4,0)
        sys.disable_caseswitch()
;        txt.nl()
    }

    sub delay(uword time) { ; about a fifth of a second for each step
        ; jiffies = 12.1 * time        
        sys.wait(12 * time + ( time / 10 ))
    }

    sub input() {
        ; input a line from the cursor until the carrage return, 
        ; the carraige return is replaced by a zero to terminate a string
        str kb_buffer = "\xA0" * 81  
        ; load up the kb_buffer
        void txt.input_chars(kb_buffer)
        return

        sub as_str() -> str {
            input()
            return kb_buffer
        }
        sub as_new_str() -> uword {
            input()
            return mpf.copy(kb_buffer)
        }
        sub as_float() -> float {
            input()
            float retf = floats.parse(kb_buffer)
            return retf
        }
        sub as_word() -> word {
            input()
            word ret16s = conv.str2word(kb_buffer)
            if cx16.r15 > 0 {
                return ret16s
            }
            return -32768
        }
        sub as_uword() -> uword {
            input()
            uword ret16 = conv.str2uword(kb_buffer)
            if cx16.r15 > 0 {
                return ret16
            }
            return $FFFF
        }
        sub as_byte() -> byte {
            input()
            byte ret8s = conv.str2byte(kb_buffer)
            if cx16.r15 > 0 {
                return ret8s
            }
            return -128
        }
        sub as_ubyte() -> ubyte {
            input()
            ubyte ret8 = conv.str2ubyte(kb_buffer)
            if cx16.r15 > 0 {
                return ret8
            }
            return $FF
        }
        sub as_char() -> ubyte {
            input()
            return kb_buffer[0]
        }
    }

/*  ; unsafe if with_rom() called twice without restore() 
    sub with_rom(ubyte bank) {      ; switch rom bank
        const uword ROM_BANK_CONTROL = $0001
        ubyte oldbank = pokemon(ROM_BANK_CONTROL, bank)
        sub restore() {
            cx16.rombank(oldbank)
        }
    }
*/

    inline asmsub swap_rombank(ubyte bank @A) clobbers (X) {
        ; use this within you subroutine to switch to another rom bank
        ; you MUST use restore_rombank() before leaving your subroutine
        ; because the original bank is pushed to the stack
        ; the return from your subroutine will crash if 
        ; restore_rombank() is not called before returning
        %asm {{
            ldx 1       ; current rom bank into x
            phx         ; save it on the stack
            sta 1       ; change to the bank provided
        }}
    }

    inline asmsub restore_rombank() {
        ; the companion to swap_rombank
        ; pops the original bank from the stack and 
        ; restores it
        %asm {{
            pla         ; pull the rom bank stored by swap_rombank()
            sta 1       ; change back to the original rom bank
        }}
    }


    sub tone(ubyte z) {
        ; sound a tone
        bool init_ym = true
        uword freq

        if init_ym {
            swap_rombank(10)    
                void cx16.ym_init()             ; use the ym synth
                cx16.ym_loadpatch(0, 160, true)    ; pure sine wave
                void cx16.ym_setatten(0,0)         ; 0 is loudest
            restore_rombank()
            init_ym = false
        }

        when z {
            10 -> freq = 137 ; octave 3 c#
            20 -> freq = 149 ; octave 3 d 
            35 -> freq = 174 ; octave 3 f
            40 -> freq = 184 ; octave 3 f#
            50 -> freq = 208 ; octave 3 g#
            60 -> freq = 239 ; octave 3 a#
            62 -> freq = 246 ; octave 3 b
            64 -> freq = 254 ; octave 4 c
            100 -> freq = 592 ; octave 5 d
        }

        swap_rombank(10)
            void cx16.bas_fmfreq(0, freq, true)      ; play the frequency
        restore_rombank()

        sys.wait(9)                             ; stall

        swap_rombank(10)
            void cx16.bas_fmfreq(0, 0, true)         ; silence the tone
        restore_rombank()
/*
        ubyte[40] snd

        sys.wait(60)

        string.copy("i160v63p3l4", snd )

        when z {
            10 -> string.append(snd, "o3c+") ; octave 3 c#
            20 -> string.append(snd, "o3d")  ; octave 3 d 
            35 -> string.append(snd, "o3f")  ; octave 3 f
            40 -> string.append(snd, "o3f+") ; octave 3 f#
            50 -> string.append(snd, "o3g+") ; octave 3 g#
            60 -> string.append(snd, "o3a+") ; octave 3 a#
            62 -> string.append(snd, "o3b")  ; octave 3 b
            64 -> string.append(snd, "o4c")  ; octave 4 c
            100 -> string.append(snd, "o5drrr") ; octave 5 d
        }

    ;    txt.print("press a key ")
        txt.print(snd)
    ;    void txt.waitkey()

        swap_rombank(10)
            void cx16.ym_init() 
;            cx16.ym_playdrum(0,27)  ;55
            cx16.bas_playstringvoice(0)
            cx16.bas_fmchordstring(string.length(snd), snd)
            cx16.bas_playstringvoice(0)
;            cx16.bas_fmchordstring(3, "rrr")
       restore_rombank()
*/       
    }

    inline asmsub nop() { %asm {{ nop }} } 
 
    sub a_set(uword base, uword offset, uword value) {
            
        %asm {{
			asl  p8v_offset
			rol  p8v_offset+1
			ldy  p8v_base+1
			lda  p8v_base
			clc
			adc  p8v_offset
    		tax
			tya
			adc  p8v_offset+1
			tay
			txa
			sta  P8ZP_SCRATCH_W2        ; base + offset
			sty  P8ZP_SCRATCH_W2+1
            lda  p8v_value
			sta  (P8ZP_SCRATCH_W2)
			lda  p8v_value+1
			ldy  #1
			sta  (P8ZP_SCRATCH_W2),y
			rts            
        }}

    }

    sub a_get(uword base, uword offset) -> uword {
        
        %asm {{
			asl  p8v_offset
			rol  p8v_offset+1
			ldy  p8v_base+1
			lda  p8v_base
			clc
			adc  p8v_offset
			tax
			tya
			adc  p8v_offset+1
			tay
			txa
			sta  P8ZP_SCRATCH_W2       ; base + offset 
			sty  P8ZP_SCRATCH_W2+1
			ldy  #1
			lda  (P8ZP_SCRATCH_W2),y
        	tay
            lda  (P8ZP_SCRATCH_W2)
			rts
        }}
    }

    sub Sa(uword base, ubyte index, uword value) {
        ; Set the value in the base array at index
        base += index << 1
        pokew(base,value)
    }

    sub Ga(uword base, ubyte index) -> uword {
        ; Get the value at base array at index
        base += index << 1
        return peekw(base)
    }

    sub available_golden_ram() -> uword {
        return mpg.available()
    }

    sub available_banked_ram(ubyte bank) -> uword {
        return mpb.available(bank)
    }

} ; end lk block

pr {  ; a collection of print helpers, thanks to @MarkTheStrange on Discord
    %option ignore_unused

    ; print string, but skip it if the pointer is zero
    sub optprint(uword s) { if s != 0 txt.print(s) }

    ; txt.print_* functions with a newline at the end
    sub println(uword s) { txt.print(s) txt.nl() }
    sub println_ub0(ubyte value) { txt.print_ub0(value) txt.nl() }
    sub println_ub(ubyte value) { txt.print_ub(value) txt.nl() }
    sub println_b(byte value) { txt.print_b(value) txt.nl() }
    sub println_ubhex(ubyte value, bool prefix) { txt.print_ubhex(value, prefix) txt.nl() }
    sub println_ubbin(ubyte value, bool prefix) { txt.print_ubbin(value, prefix) txt.nl() }
    sub println_uwbin(uword value, bool prefix) { txt.print_uwbin(value, prefix) txt.nl() }
    sub println_uwhex(uword value, bool prefix) { txt.print_uwhex(value, prefix) txt.nl() }
    sub println_uw0(uword value) { txt.print_uw0(value) txt.nl() }
    sub println_uw(uword value) { txt.print_uw(value) txt.nl() }
    sub println_w(word value) { txt.print_w(value) txt.nl() }
    sub println_f(float value) { floats.print(value) txt.nl() }
    sub println_c(ubyte value) { txt.chrout(value) txt.nl() }

    ; txt.print_* functions with a (possibly null) string on either side
    sub print_ss    (uword before,              uword after)              { optprint(before)                                optprint(after) }
    sub print_sub0  (uword before, ubyte value, uword after)              { optprint(before) txt.print_ub0(value)           optprint(after) }
    sub print_sub   (uword before, ubyte value, uword after)              { optprint(before) txt.print_ub(value)            optprint(after) }
    sub print_sb    (uword before,  byte value, uword after)              { optprint(before) txt.print_b(value)             optprint(after) }
    sub print_subhex(uword before, ubyte value, bool prefix, uword after) { optprint(before) txt.print_ubhex(value, prefix) optprint(after) }
    sub print_subbin(uword before, ubyte value, bool prefix, uword after) { optprint(before) txt.print_ubbin(value, prefix) optprint(after) }
    sub print_suwbin(uword before, uword value, bool prefix, uword after) { optprint(before) txt.print_uwbin(value, prefix) optprint(after) }
    sub print_suwhex(uword before, uword value, bool prefix, uword after) { optprint(before) txt.print_uwhex(value, prefix) optprint(after) }
    sub print_suw0  (uword before, uword value, uword after)              { optprint(before) txt.print_uw0(value)           optprint(after) }
    sub print_suw   (uword before, uword value, uword after)              { optprint(before) txt.print_uw(value)            optprint(after) }
    sub print_sw    (uword before, word value, uword after)               { optprint(before) txt.print_w(value)             optprint(after) }
    sub print_sf    (uword before, float value, uword after)              { optprint(before) floats.print(value)          optprint(after) }
    sub print_sc    (uword before, ubyte value, uword after)              { optprint(before) txt.chrout(value)              optprint(after) }

    ; txt.print_* functions with a (possibly null) string on either side and a newline at the end
    sub println_ss    (uword before,              uword after)              { optprint(before)                                optprint(after) txt.nl() }
    sub println_sub0  (uword before, ubyte value, uword after)              { optprint(before) txt.print_ub0(value)           optprint(after) txt.nl() }
    sub println_sub   (uword before, ubyte value, uword after)              { optprint(before) txt.print_ub(value)            optprint(after) txt.nl() }
    sub println_sb    (uword before, byte  value, uword after)              { optprint(before) txt.print_b(value)             optprint(after) txt.nl() }
    sub println_subhex(uword before, ubyte value, bool prefix, uword after) { optprint(before) txt.print_ubhex(value, prefix) optprint(after) txt.nl() }
    sub println_subbin(uword before, ubyte value, bool prefix, uword after) { optprint(before) txt.print_ubbin(value, prefix) optprint(after) txt.nl() }
    sub println_suwbin(uword before, uword value, bool prefix, uword after) { optprint(before) txt.print_uwbin(value, prefix) optprint(after) txt.nl() }
    sub println_suwhex(uword before, uword value, bool prefix, uword after) { optprint(before) txt.print_uwhex(value, prefix) optprint(after) txt.nl() }
    sub println_suw0  (uword before, uword value, uword after)              { optprint(before) txt.print_uw0(value)           optprint(after) txt.nl() }
    sub println_suw   (uword before, uword value, uword after)              { optprint(before) txt.print_uw(value)            optprint(after) txt.nl() }
    sub println_sw    (uword before, word  value,  uword after)             { optprint(before) txt.print_w(value)             optprint(after) txt.nl() }
    sub println_sf    (uword before, float value, uword after)              { optprint(before) floats.print(value)          optprint(after) txt.nl() }
    sub println_sc    (uword before, ubyte value, uword after)              { optprint(before) txt.chrout(value)              optprint(after) txt.nl() }

    sub nl(ubyte times) { repeat times { txt.nl() } }

    sub print_f(float value) { floats.print(value) }

    sub newchr2str(ubyte char) -> str {
        str newchrstr = "?"
        newchrstr[0] = char
        return newchrstr
    }

    sub bell() {
        txt.chrout($07)
    }

    asmsub screen_width() -> ubyte @A {
        %asm {{
            jsr cbm.SCREEN
            txa
            rts
        }}
    }

    asmsub screen_height() -> ubyte @A {
        %asm {{
            jsr cbm.SCREEN
            tya
            rts
        }}
    }

    sub clear_row(ubyte row) {
        txt.plot(0,row)
        repeat screen_width() {
            txt.spc()
        }
    }

    asmsub waitkey() -> ubyte @A {
        ; this one clears extra keystrokes in the buffer
        %asm {{
            jsr txt.waitkey
            pha
            jsr cbm.kbdbuf_clear
            pla
            rts
        }}
    }

    asmsub getin() -> ubyte @A {
        ; will return 0 when no key is pressed
        ; this one clears extra keystrokes in the buffer
        %asm {{
            jsr cbm.GETIN
            pha
            jsr cbm.kbdbuf_clear
            pla
            rts 
        }}
    }
} ; end pr block
