From: Rahul Chaturvedi <justanotheraliasforrahul@yahoo.com>
Date: Wed, 14 Apr 2004 05:05:56 +0000
Subject: RE: Questions on the stack for IA64
Message-Id: <20040414050556.34335.qmail@web61203.mail.yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
In-Reply-To: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> >c.) How exactly is the data stored in the bspstore
> >locations?
>=20
> The processor writes out stacked registers to the
> bspstore
> area "in the background" while other execution is
> happening.

Does the compiler ever touch this backing store?
I believe it is used during a stack unwind?


> >b.) There is something called $GP and $TP that the
> >compiler defines as r1 and r13 respectively. Anyone
> >got any idea what they are?
>=20
> r1 is used for simple access to some of the data,
> without
> it you would need to use "movl reg=3D<64-bit value>"
> to get
> the address of a global.  Using it, many data
> objects can
> be accessed using relative addressing from the $GP,
> a.k.a.
> __gp address.  $TP is used in the same way for
> thread local
> storage.

Thanks, the code makes a lot more sense now :)

> Can you provide a sample of C-code that results in
> this
> excessive storing to memory?

(I hope this e-mail is still readable after all this
code pasted in here =3D\)

+++------------------------------+++
int func(char* pszTest, int iTest, long lTest)
{
        int a, b, c, d, e, f, g, h, i, j, k, l, m, n,
o, p, q, r, s, t, u, v, w, x, y, z;

        a =3D 1; b =3D 2; c =3D 3; d =3D 4; e =3D 5; f =3D 6; g 7; h =3D 8;=
 i =3D 9; j =3D 10; k =3D 11; l =3D 12; m =3D 13;
	n =3D 14; o =3D 15; p =3D 16; q =3D 17; r =3D 18; s =3D 19; t 20; u =3D 21=
; v =3D 22; w =3D 23; x =3D 24; y =3D 25; z =3D 26;

        printf("", a, b, c, d, e, f, g, h, i, j, k, l,
m, n, o, p, q, r, s, t, u, v, w, x, y, z, aa, bb, cc,
dd, ee, ff, gg);

        c =3D temp(a, b);
        return 0;
}
+++------------------------------+++
=20
This code when compiled with gcc -g -O2 gives me this
assembly,

+++------------------------------+++
(From objdump) The function starts with,

int func(char* pszTest, int iTest, long lTest)
{
4000000000000680:       00 08 2d 06 80 05       [MII]=20
     alloc r33=3Dar.pfs,11,3,0

Then corresponding to these lines,


        int a, b, c, d, e, f, g, h, i, j, k, l, m, n,
o, p, q, r, s, t, u, v, w, x, y, z;

        a =3D 1; b =3D 2; c =3D 3; d =3D 4; e =3D 5; f =3D 6; g 7; h =3D 8;=
 i =3D 9; j =3D 10; k =3D 11; l =3D 12; m =3D 13;
	n =3D 14; o =3D 15; p =3D 16; q =3D 17; r =3D 18; s =3D 19; t 20; u =3D 21=
; v =3D 22; w =3D 23; x =3D 24; y =3D 25; z =3D 26;

        printf("", a, b, c, d, e, f, g, h, i, j, k, l,
m, n, o, p, q, r, s, t, u, v, w, x, y, z, aa, bb, cc,
dd, ee, ff, gg);


This is the assembly code,
4000000000000686:       c0 00 33 7c 46 c0            =20
     adds r12=3D-160,r12
400000000000068c:       81 00 00 90                  =20
     mov r14=3D8
4000000000000690:       09 28 09 00 00 24       [MMI]=20
     mov r37=3D2
4000000000000696:       60 1a 00 00 48 e0            =20
     mov r38=3D3
400000000000069c:       44 00 00 90                  =20
     mov r39=3D4;;
40000000000006a0:       00 78 40 18 00 21       [MII]=20
     adds r15=16,r12
40000000000006a6:       00 c1 30 00 42 20            =20
     adds r16$,r12
40000000000006ac:       02 62 00 84                  =20
     adds r172,r12
40000000000006b0:       00 90 a0 18 00 21       [MII]=20
     adds r18@,r12
40000000000006b6:       30 81 31 00 42 80            =20
     adds r19H,r12
40000000000006bc:       82 63 00 84                  =20
     adds r20V,r12
40000000000006c0:       09 a8 00 19 00 21       [MMI]=20
     adds r21d,r12
40000000000006c6:       60 41 32 00 42 00            =20
     adds r22r,r12
40000000000006cc:       00 00 04 00                  =20
     nop.i 0x0;;
40000000000006d0:       00 00 38 1e 90 11       [MII]=20
     st4 [r15]=3Dr14
40000000000006d6:       e0 48 00 00 48 e0            =20
     mov r14=3D9
40000000000006dc:       02 65 00 84                  =20
     adds r23=80,r12
40000000000006e0:       0a c0 60 19 00 21       [MMI]=20
     adds r24=88,r12;;
40000000000006e6:       00 70 40 20 23 c0            =20
     st4 [r16]=3Dr14
40000000000006ec:       a1 00 00 90                  =20
     mov r14=10
40000000000006f0:       02 c8 80 19 00 21       [MII]=20
     adds r25=96,r12
40000000000006f6:       a0 41 33 00 42 60            =20
     adds r26=104,r12;;
40000000000006fc:       03 67 00 84                  =20
     adds r27=112,r12
4000000000000700:       09 00 38 22 90 11       [MMI]=20
     st4 [r17]=3Dr14
4000000000000706:       e0 58 00 00 48 80            =20
     mov r14=11
400000000000070c:       83 67 00 84                  =20
     adds r28=120,r12;;
4000000000000710:       00 00 38 24 90 11       [MII]=20
     st4 [r18]=3Dr14
4000000000000716:       e0 60 00 00 48 a0            =20
     mov r14=12
400000000000071c:       03 60 04 84                  =20
     adds r29=128,r12
4000000000000720:       0a f0 20 18 01 21       [MMI]=20
     adds r30=136,r12;;
4000000000000726:       00 70 4c 20 23 c0            =20
     st4 [r19]=3Dr14
400000000000072c:       d1 00 00 90                  =20
     mov r14=13
4000000000000730:       02 f8 40 18 01 21       [MII]=20
     adds r31=144,r12
4000000000000736:       80 c0 30 02 42 20            =20
     adds r8=152,r12;;
400000000000073c:       01 62 04 84                  =20
     adds r9=160,r12
4000000000000740:       09 00 38 28 90 11       [MMI]=20
     st4 [r20]=3Dr14
4000000000000746:       e0 70 00 00 48 60            =20
     mov r14=14
400000000000074c:       04 0d 00 90                  =20
     addl r35=80,r1;;
4000000000000750:       00 00 38 2a 90 11       [MII]=20
     st4 [r21]=3Dr14
4000000000000756:       e0 78 00 00 48 40            =20
     mov r14=15
400000000000075c:       04 08 00 84                  =20
     mov r34=3Dr1
4000000000000760:       0a 40 15 00 00 24       [MMI]=20
     mov r40=3D5;;
4000000000000766:       00 70 58 20 23 c0            =20
     st4 [r22]=3Dr14
400000000000076c:       01 01 00 90                  =20
     mov r14=16
4000000000000770:       02 48 19 00 00 24       [MII]=20
     mov r41=3D6
4000000000000776:       a0 3a 00 00 48 00            =20
     mov r42=3D7;;
400000000000077c:       04 00 c4 00                  =20
     mov r32=B0
4000000000000780:       09 00 38 2e 90 11       [MMI]=20
     st4 [r23]=3Dr14
4000000000000786:       e0 88 00 00 48 80            =20
     mov r14=17
400000000000078c:       14 00 00 90                  =20
     mov r36=3D1;;
4000000000000790:       00 00 38 30 90 11       [MII]=20
     st4 [r24]=3Dr14
4000000000000796:       e0 90 00 00 48 00            =20
     mov r14=18
400000000000079c:       00 00 04 00                  =20
     nop.i 0x0
40000000000007a0:       0b 18 01 46 18 10       [MMI]=20
     ld8 r35=3D[r35];;
40000000000007a6:       00 70 64 20 23 c0            =20
     st4 [r25]=3Dr14
40000000000007ac:       31 01 00 90                  =20
     mov r14=19;;
40000000000007b0:       02 00 38 34 90 11       [MII]=20
     st4 [r26]=3Dr14
40000000000007b6:       e0 a0 00 00 48 00            =20
     mov r14 ;;
40000000000007bc:       00 00 04 00                  =20
     nop.i 0x0
40000000000007c0:       02 00 38 36 90 11       [MII]=20
     st4 [r27]=3Dr14
40000000000007c6:       e0 a8 00 00 48 00            =20
     mov r14!;;
40000000000007cc:       00 00 04 00                  =20
     nop.i 0x0
40000000000007d0:       02 00 38 38 90 11       [MII]=20
     st4 [r28]=3Dr14
40000000000007d6:       e0 b0 00 00 48 00            =20
     mov r14";;
40000000000007dc:       00 00 04 00                  =20
     nop.i 0x0
40000000000007e0:       02 00 38 3a 90 11       [MII]=20
     st4 [r29]=3Dr14
40000000000007e6:       e0 b8 00 00 48 00            =20
     mov r14#;;
40000000000007ec:       00 00 04 00                  =20
     nop.i 0x0
40000000000007f0:       02 00 38 3c 90 11       [MII]=20
     st4 [r30]=3Dr14
40000000000007f6:       e0 c0 00 00 48 00            =20
     mov r14$;;
40000000000007fc:       00 00 04 00                  =20
     nop.i 0x0
4000000000000800:       02 00 38 3e 90 11       [MII]=20
     st4 [r31]=3Dr14
4000000000000806:       e0 c8 00 00 48 00            =20
     mov r14%;;
400000000000080c:       00 00 04 00                  =20
     nop.i 0x0
4000000000000810:       02 00 38 10 90 11       [MII]=20
     st4 [r8]=3Dr14
4000000000000816:       e0 d0 00 00 48 00            =20
     mov r14&;;
400000000000081c:       00 00 04 00                  =20
     nop.i 0x0
4000000000000820:       11 00 38 12 90 11       [MIB]=20
     st4 [r9]=3Dr14
4000000000000826:       00 00 00 02 00 00            =20
     nop.i 0x0
400000000000082c:       28 fc ff 58                  =20
     br.call.sptk.many b0@00000000000440
<_init+0x150>;;
4000000000000830:       00 08 00 44 00 21       [MII]=20
     mov r1=3Dr34
+++------------------------------+++


As you can see, almost all the parameters are being
"st4'd" to memory. From the architecture
specification, shouldn't all these be moved into
registers? I have a total of much lesser than 96
parameters?


Code with lesser parameters (around 2-3) seems to use
registers fine though.

In the same code, corresponding to,

        c =3D temp(a, b);

The corresponding assembly is,

4000000000000836:       30 0a 00 00 48 80            =20
     mov r35=3D1
400000000000083c:       24 00 00 90                  =20
     mov r36=3D2
4000000000000840:       1d 00 00 00 01 00       [MFB]=20
     nop.m 0x0
4000000000000846:       00 00 00 02 00 00            =20
     nop.f 0x0
400000000000084c:       e8 fd ff 58                  =20
     br.call.sptk.many b0@00000000000620 <temp>;;



The register stack has more than enough registers to
handle 26 input's, 26 outputs and 26 local variables,
so why would it not put all the locals into registers
and pass them onto printf?


>>>>> Luck, Tony wrote on Tuesday, April 13, 2004 9:26
AM

> >Rahul Chaturvedi wrote on Monday, April 12, 2004
10:17 PM
> >d.) The pfs register seems to point to a location
in
> >0xcxxxxxxxxxxxxxxx. Shouldn't this point to some
> >accessible memory location (from usermode)?
>
> someone else can take this one?

ar.pfs is not a memory address pointer. See section
3.1.8.10 of
ia64 software developer's manual, volume 1 for proper
way to
decode that register (FYI, bit [63-62] is previous
privilege
level, which is 3 in the above case).

- Ken

Alright, okay, that also makes more sense now :)
I didn't look for the format for the pfs, I assumed it
was just a memory address.


=09
	=09
__________________________________
Do you Yahoo!?
Yahoo! Tax Center - File online by April 15th
http://taxes.yahoo.com/filing.html
