; lk_mem.p8
; built as an import file for programs that need memory allocation at runtime
%import syslib
%import string
%option ignore_unused

mpg { ; memory / string from pool from GOLDEN ram
    %option ignore_unused

    ; allocates memory from the GOLDEN pool
    ; golden memory as $0400 - $07FF  - 1K

    ; alloc(), copy() and append() will return 0 if the request cannot be met

    ; CAUTION: once allocated, storage cannot be freed 

    const uword GOLDEN_MEMORY_START = $0400
    const uword GOLDEN_MEMORY_LIMIT = $07ff

    uword current = 0

    sub init_golden() -> uword {  ; returns the current golden memory size, max 1K
        ; current available size in cx16.r0
        ; may be called multiple times
        if current == 0 {
            current = GOLDEN_MEMORY_START
        }
        ; allow caller to see where the current pointer is in cx16.r0
        ; useful if boundry alignment is required
        cx16.r0 = current
        return GOLDEN_MEMORY_LIMIT - current
     }

    sub available() -> uword { ; returns current available golden memory size, max 1K
        ; allow caller to see where the current pointer is in cx16.r0
        ; useful if boundry alignment is required
        cx16.r0 = current
        return GOLDEN_MEMORY_LIMIT - current
    }

    sub alloc(uword a_size, bool a_clear) -> uword {
        ; address of allocation or zero for fail

        if init_golden() >= a_size {
            uword alloc_start = current
            if a_clear {
                repeat a_size {
                    @(current) = $00
                    current++
                }
            } else {
               current += a_size
            }
            return alloc_start
        } else {
            return 0
        }
    }

    sub alloc_16(uword asize, bool a_clear) -> uword {
        return alloc(asize << 1, a_clear)
    }

    sub copy(str source) -> uword { 
        ; address of copied string or 0 if failed
        uword s_new = alloc(string.length(source)+1, false)
        if s_new > 0 {
           void string.copy(source, s_new)
        }
        return s_new
    }

    sub append(str source, str tail) -> uword { 
        ; address of appended string or 0 if failed
        ; note the storage for source and tail is still in use
        uword s_new = alloc(string.length(source)+1 + string.length(tail), false)
        if s_new > 0 {
           void string.copy(source, s_new)
           void string.append(s_new, tail)
        }
        return s_new
    }

}  ; end mpg block

mpf { ; memory / string from pool from FIXED memory at the end of the program
    %option ignore_unused

    ; allocates memory from the FIXED pool
    ; fixed memory that portion left in memory above the Prog8 program up to $9EFF
    ; fixed memory has the potential to be the largest or smallest pool

    ; alloc(), copy() and append() will return 0 if the request cannot be met

    ; CAUTION: once allocated, storage cannot be freed 

    const uword FIXED_MEMORY_LIMIT = $9EFF

    uword current = 0
    uword @shared limit = FIXED_MEMORY_LIMIT

    sub init_fixed() -> uword {   ; returns the fixed memory size
        ; current available size in cx16.r0
        ; may be called multiple times
        if current == 0 {
            ; round up the start of the pool to the next page
            current = sys.progend()
        }
        ; allow caller to see where the current pointer is in cx16.r0
        ; useful if boundry alignment is required
        cx16.r0 = current
        return  limit - current
    }

    sub available() -> uword {  ; returns the currently available fixed memory size
        ; allow caller to see where the current pointer is in cx16.r0
        ; useful if boundry alignment is required
        cx16.r0 = current
        return limit - current
    }

    sub alloc(uword a_size, bool a_clear) -> uword {
        ; address of allocation or zero for fail

        if init_fixed() >= a_size {
            uword alloc_start = current
            if a_clear {
                repeat a_size {
                    @(current) = $00
                    current++
                }
            } else {
               current += a_size
            }
            return alloc_start
        } else {
            return 0
        }
    }

    sub alloc_16(uword asize, bool a_clear) -> uword {
        return alloc(asize << 1, a_clear)
    }

;    sub alloc_at_limit(uword a_size, bool a_clear) -> uword {
;        ; address of allocation or zero for fail
;        ; allocate from the pool limit down
;        if init_fixed() >= a_size {
;            limit -= a_size
;            if a_clear {
;                uword alloc_start = limitok
;                repeat a_size {
;                    @(alloc_start) = $00
;                    alloc_start++
;                }
;            }
;            return limit
;        }
;        return 0
;    }

    sub copy(str source) -> uword { 
        ; address of copied string or 0 if failed
        uword s_new = alloc(string.length(source)+1, false)
        if s_new > 0 {
           void string.copy(source, s_new)
        }
        return s_new
    }

    sub append(str source, str tail) -> uword { 
        ; address of appended string or 0 if failed
        ; note the storage for source and tail is still in use
        uword s_new = alloc(string.length(source)+1 + string.length(tail), false)
        if s_new > 0 {
           void string.copy(source, s_new)
           void string.append(s_new, tail)
        }
        return s_new
    }

}  ; end mpf block


mpb { ; banked memory pool
    %option ignore_unused

    ; allocates memory from the banked High memory
    ; each bank is located in memory from $A000 - $BFFF
    ; one bank is 8K in size
    ; set the number of banks your program will use 
    ; with NUMBER_OF_BANKS_REQUESTED
    ; bank 0 is reserved for system use and may not
    ; be allocated by user programs
    ; systems with standard ram of 512 MB may only use
    ; banks 1 - 63

    const uword RAM_BANK_CONTROL = $0000

    const uword INVALID_BANK = $FFFF

    const uword HIGH_MEMORY_START = $A000
    const uword HIGH_MEMORY_LIMIT = $BFFF

    const ubyte NUMBER_OF_BANKS_REQUESTED = 3  ; valid range 1 - 255

    uword[NUMBER_OF_BANKS_REQUESTED + 1] current = 0

    sub init_bank(ubyte bank) -> uword { ; returns the current available size
        if bank == 0 or bank > NUMBER_OF_BANKS_REQUESTED {
            cx16.r0 = 0
            return INVALID_BANK
        }
        if current[bank] == 0 {
            current[bank] = HIGH_MEMORY_START
        }       
        cx16.r0 = current[bank]  ; the beginning of the next alloc
        return HIGH_MEMORY_LIMIT - current[bank]
    }

    sub available(ubyte bank) -> uword { ; returns the current available size
        if bank == 0 {  ; no valid bank 0
        } else if bank > NUMBER_OF_BANKS_REQUESTED {
        } else if current[bank] == 0 {  ; no init_bank() called
        } else {
            ; normal return
            cx16.r0 = current[bank]   ; the beginning of the next alloc
            return HIGH_MEMORY_LIMIT - current[bank]
        }
        ; error return
        cx16.r0 = 0
        return 0 
    }

    sub alloc(ubyte bank, uword a_size, bool a_clear) -> uword {
        if a_size > init_bank(bank) {
            return 0
        }
        uword alloc_start = current[bank]
        if a_clear {
            repeat a_size {
                @(current[bank]) = $00 
                current[bank]++
            }
        } else {       
            current[bank] += a_size
        }
        return alloc_start
    }

    sub alloc_16(ubyte bank, uword asize, bool a_clear) -> uword {
        return alloc(bank, asize << 1, a_clear)
    }

    sub copy(ubyte bank, str source) -> uword { 
        ; address of copied string or 0 if failed
        uword s_new = alloc(bank, string.length(source)+1, false)
        if s_new > 0 {
            swap_rambank(bank)
                void string.copy(source, s_new)
            restore_rambank()    
        }
        return s_new
    }

    sub append(ubyte bank, str source, str tail) -> uword { 
        ; address of appended string or 0 if failed
        ; note the storage for source and tail is still in use
        uword s_new = alloc(bank, string.length(source)+1 + string.length(tail), false)
        if s_new > 0 {
            swap_rambank(bank)
                void string.copy(source, s_new)
                void string.append(s_new, tail)
            restore_rambank()
        }
        return s_new
    }
    
/* ; unsafe if with_ram() called twice without restore()
    sub with_ram(ubyte bank) {      ; switch ram bank
        ; may be used if you need to restore 
        ; the original bank in a parent of 
        ; the subroutine that calls mpb.with_ram()
        ; you need to call mpb.with_ram.restore() to 
        ; put the original bank back 
        ubyte oldbank = pokemon(RAM_BANK_CONTROL, bank)
        sub restore() {
            cx16.rambank(oldbank)
        }
    }
*/
    inline asmsub swap_rambank(ubyte bank @A) clobbers (X) {
        ; use this within you subroutine to switch to another ram bank
        ; you MUST use restore_rambank() before leaving your subroutine
        ; because the original bank is pushed to the stack
        ; the return from your subroutine will crash if 
        ; restore_rambank() is not called before returning
        %asm {{
            ldx 0       ; current ram bank into x
            phx         ; save it on the stack
            sta 0       ; change to the bank provided
        }}
    }

    inline asmsub restore_rambank() clobbers (A) {
        ; the companion to swap_rambank
        ; pops the original bank from the stack and 
        ; restores it
        %asm {{
            pla         ; pull the ram bank stored by swap_rambank()
            sta 0       ; change back to the original ram bank
        }}
    }

} ; end mpb block
