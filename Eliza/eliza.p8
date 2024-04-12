; eliza.p8
%import lk_import
%zeropage basicsafe
%option no_sysinit

; this is a port of a BASIC program found in the book
; More BASIC Computer Games, edited by David H. Ahl
; published by Workman Publishing New York in 1979
; Eliza can be found on page 56
;
; This program compiles with Prog8 distributions later than 
; April 10th 2024

main {
    const ubyte N1 = 36
    const ubyte N2 = 16
    const ubyte N3 = 112

    uword c_str     ; conjugated string
    uword p_str     ; previous input string  
    uword i_str     ; input string
    uword k_str     ; keyword string
    uword f_str     ; reply string
    uword r_str     ; conjugation first string
    uword s_str     ; conjugation second string

    ubyte[N1] s     ; keyword array first reply
    ubyte[N1] r     ; keyword array next reply
    ubyte[N1] n     ; keyword array last reply

    ubyte     k     ; keyword
    ubyte     s1
    ubyte     t
    ubyte     x
    ubyte     l
    ubyte     o   ; findstr() offset

    sub start() {

        init()
        print("hi! i'm eliza. what's your problem?")
        txt.print("? ")

        repeat {
            i_str = ""
            c_str = ""
            f_str = ""
            if input() {
                if keyword() {
                    conjugate()
                }                
                reply()
            }
        }
    }

    sub init() {
        ; set up the reply logic arrays
        for x in 0 to N1 - 1 {
            s[x] = data.reply_logic[x*2]
            r[x] = s[x]
            n[x] = s[x] + data.reply_logic[x*2+1] 
        }
        p_str = ""
    }

    sub input() -> bool {
        i_str = lk.input.as_str()
        txt.nl()
        txt.nl()
        i_str = cat1.build(" ",i_str,"  ")
        i_str = cat1.purge(i_str,'\'')
        ; search for shut up in the input
        void string.findstr(i_str, "shut up")
        if_cs {
            print("shut up...")
            sys.exit(0)
        }
        if string.compare(i_str, p_str) == 0 {
            print("please don't repeat yourself!")
            return false
        }
        return true
    }

    sub keyword() -> bool {
        s1 = $ff
        for k in 0 to N1 - 1 {
            k_str = data.keywords[k]
            o = string.findstr(i_str, k_str)
            if_cs {
                t = o
                s1 = k
                f_str = k_str
                break
            }
        }
        if s1 == $ff {
            k = 35
            return false
        } 
        k = s1
        l = t     
        return true
    }

    sub conjugate() {
        c_str = cat2.build(" ",i_str+l+ln(f_str)," ") ; right of keyword   
        for x in 0 to N2 - 2 step 2 {
            s_str = data.conj[x]
            r_str = data.conj[x+1]
            for l in 0 to ln(c_str) - 1 {
                if l >= ln(c_str) - ln(s_str) break
                o = string.findstr(c_str+l, s_str)
                if_cs {
                    c_str[l+o] = 0 ; give it an end at the found word string
                    c_str = cat2.build(c_str, r_str, c_str+o+ln(s_str))
                    l += o + ln(r_str)
                }
                if l >= ln(c_str) - ln(r_str) break
                o = string.findstr(c_str+l,r_str)
                if_cs {
                    c_str[l+o] = 0                  
                    c_str = cat2.build(c_str,s_str,c_str+o+ln(r_str))
                    l += o + ln(s_str)
                }
            }
        }
        if c_str[1] == ' ' {
            c_str = cat2.remove_chr_at(c_str,1)
        }
        c_str = cat2.purge(c_str,'!')
    }

    sub reply() {
        f_str = data.reply[r[k]]
        r[k] += 1
        if r[k] > n[k] {
            r[k] = s[k]
        }
        if string.endswith(f_str,"*") {
            f_str[ln(f_str)-1] = 0
            txt.print(f_str)
            print(c_str)
        } else {
            print(f_str)
        }
        p_str = cat3.set_string(i_str)
        txt.print("? ")
    }

    sub print(uword message) {  ; don't crowd the lines
        txt.print(message)
        txt.nl()
        txt.nl()
    }

    inline asmsub ln(uword s @AY) clobbers(A) -> ubyte @Y {
        %asm{{
            jsr string.length
        }}
    }
}



cat1 {  ; used by i_str
    ubyte[83] buffer
    ubyte     x
    sub build(uword p1, uword p2, uword p3) -> uword {
        void string.copy(p1,buffer)
        void string.append(buffer,p2)
        void string.append(buffer,p3)
        return buffer
    }

    sub remove_chr_at(uword p1, ubyte offset) -> uword {
        void string.copy(p1,buffer)
        buffer[offset] = 0
        void string.append(buffer,p1+offset+1)
        return buffer
    }

    sub purge(uword p1, ubyte chr) -> uword {
        repeat {
            x,void = string.find(p1, chr)
            if_cs {
                p1 = remove_chr_at(p1,x)
            } else {
                break
            }
        } 
        return p1
    }
}

cat2 { ; used by c_str
    ubyte[83] bufferA
    ubyte[83] bufferB
    uword     buff
    ubyte     x
    sub set_buff(uword p1) {
        buff = &bufferA
        if p1 ^ &bufferA == 0 {
            buff = &bufferB
        }
    }

    sub build(uword p1, uword p2, uword p3) -> uword {
        set_buff(p1)
        void string.copy(p1,buff)
        void string.append(buff,p2)
        void string.append(buff,p3)
        return buff
    }

    sub remove_chr_at(uword p1, ubyte offset) -> uword {
        set_buff(p1)
        void string.copy(p1,buff)
        buff[offset] = 0
        void string.append(buff,p1+offset+1)
        return buff
    }

    sub purge(uword p1, ubyte chr) -> uword {
        repeat {
            x,void = string.find(p1, chr)
            if_cs {
                p1 = remove_chr_at(p1,x)
            } else {
                break
            }
        } 
        return p1
    }
}

cat3 { ; used by p_str
    ubyte[83] buffer
    sub set_string(uword p1) -> uword {
        void string.copy(p1,buffer)
        return buffer
    }
}

data {
    uword[] keywords = [
        "can you","can i","you are","youre","i dont","i feel",
        "why dont you","why cant i","are you","i cant","i am","im ",
        "you ","i want","what","how","who","where","when","why",
        "name","cause","sorry","dream","hello","hi ","maybe",
        "no","your","always","think","alike","yes","friend",
        "computer","nokeyfound"
    ]

    uword[] conj = [
        " are "," am ","were ","was "," you "," i ","your ","my ",
        " ive "," youve "," in "," youre ",
        " me "," !you "," me?"," you?"
    ]

    uword[] reply = [
        "",
        "don't you believe that i can*",
        "perhaps you would like to be able to*",
        "you want me to be able to*",
        "perhaps you don't want to*",
        "do you want to be able to*",
        "what makes you think i am*",
        "does it please you to believe i am*",
        "perhaps you would like to be*",
        "do you sometimes wish you were*",
        "don't you really*",
        "why don't you*",
        "do you wish to be able to*",
        "does that trouble you?",
        "tell me more about such feelings.",
        "do you often feel*",
        "do you enjoy feeling*",
        "do you really believe i don't*",
        "perhaps in good time i will*",
        "do you want me to*",
        "do you think you should be able to*",
        "why can't you*",
        "why are you interested in whether or not i am*",
        "would you prefer if i were not*",
        "perhaps in your fantasies i am*",
        "how do you know i can't*",
        "have you tried?",
        "perhaps you can now*",
        "did you come to me because you are*",
        "how long have you been*",
        "do you believe it is normal to be*",
        "do you enjoy being*",
        "we were discussing you-- not me.",
        "oh, i*",
        "you're not really talking about me, are you?",
        "what would it mean to you if you got*",
        "why do you want*",
        "suppose you soon got*",
        "what if you never got*",
        "i sometimes also want*",
        "why do you ask?",
        "does that question interest you?",
        "what answer would please you the most?",
        "what do you think?",
        "are such questions on your mind often?",
        "what is it that you really want to know?",
        "have you asked anyone else?",
        "have you asked such questions before?",
        "what else comes to mind when you ask that?",
        "names don't interest me.",
        "i don't care about names-- please go on.",
        "is that the real reason?",
        "don't any other reasons come to mind?",
        "does that reason explain anything else?",
        "what other reasons might there be?",
        "please don't apologise!",
        "apologies are not necessary.",
        "what feelings do you have when you apologise?",
        "don't be so defensive!",
        "what does that dream suggest to you?",
        "do you dream often?",
        "what persons appear in your dreams?",
        "are you disturbed by your dreams?",
        "how do you do ... please state your problem.",
        "you don't seem quite certain.",
        "why the uncertain tone?",
        "can't you be more positive?",
        "you aren't sure?",
        "don't you know?",
        "are you saying no just to be negative?",
        "you are being a bit negative.",
        "why not?",
        "are you sure?",
        "why no?",
        "why are you concerned about my*",
        "what about your own*",
        "can you think of a specific example?",
        "when?",
        "what are you thinking of?",
        "really always?",
        "do you really think so?",
        "but you are not sure you*",
        "do you doubt you*",
        "in what way?",
        "what resemblance do you see?",
        "what does the similarity suggest to you?",
        "what other connections do you see?",
        "could there really be some connection?",
        "how?",
        "you seem quite positive.",
        "are you sure?",
        "i see.",
        "i understand.",
        "why do you bring up the topic of friends?",
        "do your friends worry you?",
        "do your friends pick on you?",
        "are you sure you have any friends?",
        "do you impose on your friends?",
        "perhaps your love for friends worries you.",
        "do computers worry you?",
        "are you talking about me in particular?",
        "are you frightened by machines?",
        "why do you mention computers?",
        "what do you think machines have to do with your problem?",
        "don't you think computers can help people?",
        "what is it about machines that worries you?",
        "say, do you have any psychological problems?",
        "what does that suggest to you?",
        "i see.",
        "i'm not sure i understand you fully.",
        "come come elucicdate your thoughts.",
        "can you elaborate on that?",
        "that is quite interesting."
    ]

    ubyte[] reply_logic = [
        1,3,4,2,6,4,6,4,10,4,14,3,17,3,20,2,22,3,25,3,
        28,4,28,4,32,3,35,5,40,9,40,9,40,9,40,9,40,9,40,9,
        49,2,51,4,55,4,59,4,63,1,63,1,64,5,69,5,74,2,76,4,
        80,3,83,7,90,3,93,6,99,7,106,7
    ]
}