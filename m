From: Steve Tynor <tynor@atlanta.twr.com>
Date: Mon, 02 Oct 2000 22:43:37 +0000
Subject: [Linux-ia64] gcc bug (2.9-ia64-000216-final)
Message-Id: <marc-linux-ia64-105590678205537@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I'm advised to delay my attempt to use the latest cygnus 0925 toolchain
given all the dependencies on other things I don't have on my machine
yet (e.g. the 2.2 glibc). So I've spent some more time understanding the
error in the 2.9-ia64-000216-final toolchain.

I have been able to distill my gcc optimization bug into the attached
simple program.  Compile with any of

       gcc test.c
       gcc -O test.c

and it will behave properly (no seg fault).  But compile with=20

       gcc -O2 test.c

and the program will seg fault in the call2() function.   Removing the
"const volatile" markup from the first argument makes the bug go away.
In fact, removing either "const" or "volatile" make it go away. But the
two together are death.  The program dies in the following instruction:=20


        Program received signal SIGSEGV, Segmentation fault.
        0x40000000000007d0 in call2 ()
        (gdb) disass
        Dump of assembler code for function call2:
        0x4000000000000790 <call2>:     [MII]       alloc r36=3Dar.pfs,7,5,0
        0x4000000000000791 <call2+1>:               mov r34=3Dr12
        0x4000000000000792 <call2+2>:               mov r35=B0
        0x40000000000007a0 <call2+16>:  [MMI]       mov r38=3Dr33;;
        0x40000000000007a1 <call2+17>:              adds r12=3D-32,r12
        0x40000000000007a2 <call2+18>:              nop.i 0x0;;
        0x40000000000007b0 <call2+32>:  [MMI]       adds r15=3D-8,r34;;
        0x40000000000007b1 <call2+33>:              ld8.acq r14=3D[r15]
        0x40000000000007b2 <call2+34>:              nop.i 0x0
        0x40000000000007c0 <call2+48>:  [MMI]       st8 [r15]=3Dr32;;
        0x40000000000007c1 <call2+49>:              adds r14=3D8,r14
        0x40000000000007c2 <call2+50>:              nop.i 0x0;;
        0x40000000000007d0 <call2+64>:  [MIB]       ld8 r37=3D[r14]
        0x40000000000007d1 <call2+65>:              nop.i 0x0
        0x40000000000007d2 <call2+66>:
                        br.call.sptk.many b0=3D0x4000000000000730 <call1>;;
        0x40000000000007e0 <call2+80>:  [MII]       mov r12=3Dr34
        0x40000000000007e1 <call2+81>:              mov.i ar.pfs=3Dr36
        0x40000000000007e2 <call2+82>:              mov b0=3Dr35
        0x40000000000007f0 <call2+96>:  [MIB]       nop.m 0x0
        0x40000000000007f1 <call2+97>:              nop.i 0x0
        0x40000000000007f2 <call2+98>:              br.ret.sptk.many b0;;
        End of assembler dump.
        (gdb) p/a $pc
        $1 =3D 0x40000000000007d0 <call2+64>
        (gdb)=20

It seems to me that the problem is that gcc has decided to read the
value of the first argument out of a stack allocated local variable
without ever having written to that stack location.  It looks like the
instruction at +48 does the store; but it is in the same group as the
attempt to load it at +33.


Can someone verify that this bug is fixed in the latest toolchain?

Thanks a bunch,
Steve



------- snip here ---------
#include <stdio.h>

typedef struct one { int a; int b;} ONE_S, *ONE;
typedef struct two { int filler; ONE c; } TWO_S, *TWO;

void call1(ONE a_one, int code) {
    printf("in call1 %lx: %d %d\n", (long) a_one, a_one->a, a_one->b);
}
void call2(const TWO volatile a_two, int code) {

    call1 (a_two->c, code);
}

int main (int argc, char* argv[]) {
    ONE_S a_one;
    TWO_S a_two;

    a_two.c =3D &a_one;

    a_one.a =3D 11;=20
    a_one.b =3D 12;=20

    printf("in main %lx: %d %d\n", (long) a_two.c, a_one.a, a_one.b);
    call2 (&a_two, 22);
}

