format PE GUI 4.0 DLL

include 'win32a.inc'

section '.text' code readable executable

srand:
        finit
        fild    [someConstant]
        fld     qword[esp + 4]      ;func parameter (seed)
        fprem
        fstp    [seed]
        ffree   st0

        push    dword[seed]
        push    dword[seed + 4]

        pop     dword[pseudoRandVal + 4]
        pop     dword[pseudoRandVal]

        push    eax
        mov     eax, [esp + 4]
        add     esp, 12
        mov     [esp], eax
        mov     eax, [esp - 12]

        ret


rand:
        finit
        ;===========================
        ;los=(a*los+b) % m

        fild    [rnd_m]
        fild    [rnd_b]
        fild    [pseudoRandVal]
        fild    [rnd_a]

        fmulp
        faddp
        fprem
        ffree   st1

        fstp    [pseudoRandVal]

        ;===========================
        ;losowa = ( los % (L2 - L1 + 1) ) + L1

        fild    dword[L1]
        fld     [pseudoRandVal]
        fld1
        fild    dword[L2]
        fild    dword[L1]

        fsubp
        faddp
        fxch
        fprem
        ffree   st1
        fadd    st0, st2
        ffree   st2


        sub     esp, 4
        fistp   dword[esp]
        pop     eax
        ;===========================
        ;EAX contains a pseudo random value [0 - 99]
        ret



transform:
       ; x' = ax + by + c
       ; y' = dx + ey + f
        push    eax
        mov     eax, [esp + 16]

        cmp     al, 49d
        jbe     useP1Set
        jmp     useP2Set

    doTrans:
        finit

        fld     [c]                          ;x
        fld     [b]                          ;a
        mov     eax, [esp + 12]  ;y          ;y
        fld     qword[eax]                   ;b
        fld     [a]                          ;c
        mov     eax, [esp + 8]   ;x          ;
        fld     qword[eax]
        fst     [localX]

        fmulp
        fxch    st2
        fmulp
        faddp
        faddp
        fstp    qword[eax]
        ;====================== y transformation

        fld     [f]                          ;x
        fld     [e]                          ;d
        mov     eax, [esp + 12]  ;y          ;y
        fld     qword[eax]                   ;e
        fld     [d]                          ;f
        fld     [localX]         ;x

        fmulp
        fxch    st2
        fmulp
        faddp
        faddp
        fstp    qword[eax]

        mov     eax, [esp + 4]
        add     esp, 16
        mov     [esp], eax
        mov     eax, [esp - 16]

        ret

useP1Set:
        fld     [a1]
        fstp    [a]
        fld     [b1]
        fstp    [b]
        fld     [c1]
        fstp    [c]
        fld     [d1]
        fstp    [d]
        fld     [e1]
        fstp    [e]
        fld     [f1]
        fstp    [f]

        jmp     doTrans

useP2Set:
        fld     [a2]
        fstp    [a]
        fld     [b2]
        fstp    [b]
        fld     [c2]
        fstp    [c]
        fld     [d2]
        fstp    [d]
        fld     [e2]
        fstp    [e]
        fld     [f2]
        fstp    [f]

        jmp     doTrans


calc_pixel:
        ;====== x` to xe =======
        push    eax
        fild    word[gx_max]
        fld     qword[x_min]
        fld     qword[x_max]
        fld     qword[esp + 8]
        fld     qword[x_min]

        fsubp
        fxch    st2
        fsubp
        fdivp
        fmulp

        mov     eax, [esp + 16]
        fistp   dword[eax]

        ;====== y` to ye =======
        fild    word[gy_max]
        fild    word[gy_max]
        fld     qword[y_min]
        fld     qword[y_max]
        fld     qword[esp + 20]
        fld     qword[y_min]

        fsubp
        fxch    st2
        fsubp
        fdivp
        fmulp
        fsubp

        mov     eax, [esp + 28]
        fistp   dword[eax]

        pop     eax
        ret

section '.data' data readable writeable
        localX dq 0

        a dq 0
        b dq 0
        c dq 0
        d dq 0
        e dq 0
        f dq 0

        a1 dq 0.202
        b1 dq -0.805
        c1 dq -0.373
        d1 dq -0.689
        e1 dq -0.342
        f1 dq -0.653

        a2 dq 0.138
        b2 dq 0.665
        c2 dq 0.660
        d2 dq -0.502
        e2 dq -0.222
        f2 dq -0.277

        rnd_a dq 13100233d
        rnd_b dq 11040857d
        rnd_m dq 9999999991d  ;zwiększenie tego współczynniku spowodowało polepszenie jakości obrazu fraktału 
        ;rnd_m dq 9999991d


        L1 dd 0d
        L2 dd 99d

        seed dq 0d
        someConstant dq 10000d
        pseudoRandVal dq 0d

        gx_max dw 800
        gy_max dw 600

        x_min dq -0.5
        x_max dq 0.8
        y_min dq -1.2
        y_max dq 0.2


section '.idata' import data readable writeable

 library kernel, 'kernel32.dll',\
         msvcrt, 'msvcrt.dll',\
         user32, 'USER32.DLL'

        import kernel, \
               ExitProcess, 'ExitProcess'

        import msvcrt, \
               printf, 'printf', \
               scanf, 'scanf', \
               getch, '_getch',\
               system,'system'

        import user32,\
               MessageBoxA,'MessageBoxA'




section '.edata' export data readable

        export 'IFS_FractalsLib.DLL',\
               srand, 'srand',\
               rand, 'rand',\
               transform, 'transform',\
               calc_pixel, 'calc_pixel'


section '.reloc' fixups data readable discardable
