; bnk_mgr.p8
%import syslib


main {
    sub start() {
        bnk_mgr.init()
        bnk_mgr.reserve_bank(21)
    }
}

bnk_mgr {
    const ubyte BANK_RESERVED = 0
    const ubyte BANK_AVAILABLE = 1
    const ubyte INVALID_GROUPID = 0
    const ubyte FIRST_GROUPID = 2
    ubyte[256] bnk_tbl
    ubyte next_groupid, i

    sub init() {
        ubyte lastbank
        next_groupid = FIRST_GROUPID
        void, lastbank = cbm.MEMTOP(0, true)
        bnk_tbl[0] = BANK_RESERVED
        for i in 1 to lastbank-1 {
            bnk_tbl[i] = BANK_AVAILABLE
        }
        if last_bank < 255 {
            for i in lastbank to 255 {
                bnk_tbl[i] = BANK_RESERVED
            }
        }
    }

    sub reserve_bank(ubyte bank) -> bool {
        if bnk_tbl[bank] != BANK_AVAILABLE {
            return false
        }
        bnk_tbl[bank] = BANK_RESERVED
        return true
    }

    ; group ids go from 2 through 255, they cannot be reused without further programming
    sub next_groupid() -> ubyte {
        sys.push(next_groupid)

        if next_groupid != INVALID_GROUPID {
            next_groupid += 1
        }

        return sys.pop()
    }

    asmsub get_groupid() -> ubyte, bool {
        @asm{{
            stp
        }}

    }

    sub get_new_bank(ubyte groupid) -> ubyte {
        ubyte new_bank = BANK_RESERVED
        for i in 0 to 255 {
            if bnk_tbl[i] == BANK_AVAILABLE {
                bnk_tbl[i] = groupid
                new_bank = i
            }
        }
        return new_bank
    }

    asmsub get_bank(ubyte groupid) -> ubyte, bool {
        @asm{{
            stp
        }}
    }

    sub free_groupid(ubyte groupid) -> bool {
        for i in 0 to 255 {
            if bnk_tbl[i] = groupid {
                bnk_tbl[i] = BANK_AVAILABLE
            }
        }
    }

}