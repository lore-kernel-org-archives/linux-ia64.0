From: Piet/Pete Delaney <piet@sgi.com>
Date: Thu, 03 Jan 2002 08:18:33 +0000
Subject: [Linux-ia64] Calling functions via function descriptors saved with cast needed for ia64 code. Illega
Message-Id: <marc-linux-ia64-105590698805733@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Jan 02, 2002 at 09:46:35PM -0800, Piet/Pete Delaney wrote:

With the cast that you (Keith Owens) suggested the assignment code seems=20
to be fine but the dereference of the pointer causes a illegal instruction =
signal.
Unfortunately the problem doesn't occure in the simple example. I suppose it
has to do with linking.

In the lcrash/lkcd case we have a resonable pointer to the function to=20
disassemble the instructions (via libopcodes.a):

(gdb) where
#0  0x400005801a415000 in ?? ()												[How did I get here?]
#1  0x400000000006d320 in dis_printintaddr (addr=3D0xe0020000006abae0, dip=
=3D0x600000000001e0c0, flag=3D0x1) at dis.c:62
#2  0x400000000006da30 in do_dis (value=3D0xe0020000006abae0, lines=3D0x1, =
ofp=3D0x20000000004a35b0) at dis.c:141
#3  0x400000000006e3a0 in print_instr_stream (v=3D0xe0020000006abae0, bcoun=
t=3D0x0, acount=3D0x0, flags=3D0x0, ofp=3D0x20000000004a35b0) at dis.c:241
#4  0x4000000000054340 in dis_cmd (cmd=3D0x6000000000255000) at cmd_dis.c:1=
64
#5  0x400000000004ca70 in do_cmd (cmd=3D0x6000000000255000) at command.c:450
#6  0x400000000004cc40 in process_cmds () at command.c:475
#7  0x4000000000011520 in main (argc=3D0x1, argv=3D0x80000fffffffb7c8) at m=
ain.c:265
(gdb)=20

(gdb) print *dip
$2 =3D {
  fprintf_func =3D 0x400000000006cfb0 <dis_fprintf>, 		<-- Pointer to funct=
ion seems to be ok
  stream =3D 0x20000000004a35b0,=20
  application_data =3D 0x0,=20
  flavour =3D bfd_target_elf_flavour,=20
  arch =3D bfd_arch_ia64,=20
  mach =3D 0x2b,=20
  endian =3D BFD_ENDIAN_LITTLE,=20
  symbols =3D 0x0,=20
  num_symbols =3D 0x0,=20
  flags =3D 0x0,=20
  private_data =3D 0x0,=20
  read_memory_func =3D 0x400000000006d0c0 <getidmem>,=20
  memory_error_func =3D 0,=20
  print_address_func =3D 0x400000000006d7f0 <dis_printaddr>,=20
  symbol_at_address_func =3D 0x400000000006d880 <dis_getsym>,=20
  buffer =3D 0x0,=20
  buffer_vma =3D 0x0,=20
  buffer_length =3D 0x0,=20
  bytes_per_line =3D 0x0,=20
  bytes_per_chunk =3D 0x0,=20
  display_endian =3D BFD_ENDIAN_LITTLE,=20
  octets_per_byte =3D 0x0,=20
  insn_info_valid =3D 0x0,=20
  branch_delay_insns =3D 0x0,=20
  data_size =3D 0x0,=20
  insn_type =3D dis_noninsn,=20
  target =3D 0x0,=20
  target2 =3D 0x0,=20
  disassembler_options =3D 0x0
}
(gdb)=20

When executing:

  47 /*=20
  48  * dis_printintaddr()
  49  */
  50 static void
  51 dis_printintaddr(bfd_vma addr, struct disassemble_info *dip, int flag)
  52 {
  53  int offset =3D 0;
  54  syment_t *sp;
  55=20
  56  if ((sp =3D kl_lkup_symaddr(addr))) {
  57   offset =3D addr - sp->s_addr;
  58  }
  59=20
  60  /* Print out address
  61   */
  62  dip->fprintf_func(dip->stream, "0x%llx", addr);				Illegal instructio=
n hit in asm code


Dump of assembler code from 0x400000000006d2b0 to 0x400000000006d3b0:
    0x400000000006d2b0 <dis_printintaddr+224>:	[MMI]       adds r14=3D-456,=
r38;;		Line 62 above....
    0x400000000006d2b1 <dis_printintaddr+225>:	            ld8 r15=3D[r14]
    0x400000000006d2b2 <dis_printintaddr+226>:	            adds r14=3D-456,=
r38;;
    0x400000000006d2c0 <dis_printintaddr+240>:	[MMI]       ld8 r14=3D[r14];;
    0x400000000006d2c1 <dis_printintaddr+241>:	            adds r14=3D8,r14
    0x400000000006d2c2 <dis_printintaddr+242>:	            nop.i 0x0
    0x400000000006d2d0 <dis_printintaddr+256>:	[MMI]       ld8 r16=3D[r15];;
    0x400000000006d2d1 <dis_printintaddr+257>:	            ld8 r39=3D[r14]
    0x400000000006d2d2 <dis_printintaddr+258>:	            addl r14=1848,r1=
;;
    0x400000000006d2e0 <dis_printintaddr+272>:	[MFI]       ld8 r40=3D[r14]
    0x400000000006d2e1 <dis_printintaddr+273>:	            nop.f 0x0
    0x400000000006d2e2 <dis_printintaddr+274>:	            adds r14=3D-464,=
r38;;
    0x400000000006d2f0 <dis_printintaddr+288>:	[MFI]       ld8 r41=3D[r14]
    0x400000000006d2f1 <dis_printintaddr+289>:	            nop.f 0x0
    0x400000000006d2f2 <dis_printintaddr+290>:	            mov r35=3Dr1
    0x400000000006d300 <dis_printintaddr+304>:	[MFI]       ld8 r15=3D[r16]
    0x400000000006d301 <dis_printintaddr+305>:	            nop.f 0x0
    0x400000000006d302 <dis_printintaddr+306>:	            adds r14=3D8,r16=
;;
    0x400000000006d310 <dis_printintaddr+320>:	[MIB]       ld8 r1=3D[r14]
    0x400000000006d311 <dis_printintaddr+321>:	            mov b6=3Dr15				=

    0x400000000006d312 <dis_printintaddr+322>:	            br.call.sptk.man=
y b0=B6;;		Get an Illegal instruction next

Registers at a breakpoint at the br.call.sptk.many b0=B6;; are shown below.=
=20
Executing the br.call.sptk.many results in a SIGILL with a pc of 0x40000580=
1a415000.
The value in registers being used are:

(gdb) info register b0										Return Address
b0             0x400000000006d320	0x400000000006d320
(gdb) info register b6										Should be dis_fprintf
b6             0x410005801a415000	0x410005801a415000
(gdb)=20

I'm still learning the asm code for ia64 and don't yet understand how
we single stepped to 0x400005801a415000 using these registers. Perhaps=20
gdb doesn't single step calls thru pointers corectly. Anyone have a clue?

I suspect another cast is needed when the function descriptor is used. Sigh!

-piet


(gdb) info registers
r0             0x0	0x0
r1             0x8cfc678220420030	0x8cfc678220420030
r2             0x80000fffffffb320	0x80000fffffffb320
r3             0x80000fffffffb710	0x80000fffffffb710
r4             0x0	0x0
r5             0x0	0x0
r6             0x0	0x0
r7             0x0	0x0
r8             0x60000000000afd30	0x60000000000afd30
r9             0x600000000001e7e0	0x600000000001e7e0
r10            0x0	0x0
r11            0x600000000000a580	0x600000000000a580
r12            0x80000fffffffb360	0x80000fffffffb360
r13            0x0	0x0
r14            0x400000000006cfb8	0x400000000006cfb8
r15            0x410005801a415000	0x410005801a415000
r16            0x400000000006cfb0	0x400000000006cfb0
r17            0x80000fffffffb330	0x80000fffffffb330
r18            0x80000fffffffb330	0x80000fffffffb330
r19            0x6000000000255000	0x6000000000255000
r20            0x0	0x0
r21            0x4000000000008390	0x4000000000008390
r22            0x6000000000253180	0x6000000000253180
r23            0x7ffff000000048ec	0x7ffff000000048ec
r24            0x10	0x10
r25            0x4	0x4
r26            0x60000000002ee678	0x60000000002ee678
r27            0x0	0x0
r28            0x40	0x40
r29            0x0	0x0
r30            0x3	0x3
r31            0x6000	0x6000
r32            0xe0020000006abae0	0xe0020000006abae0
r33            0x600000000001e0c0	0x600000000001e0c0
r34            0x1	0x1
r35            0x600000000000a140	0x600000000000a140
r36            0x400000000006da30	0x400000000006da30
r37            0xc00000000000038a	0xc00000000000038a
r38            0x80000fffffffb540	0x80000fffffffb540
r39            0x20000000004a35b0	0x20000000004a35b0
r40            0x40000000001b60d0	0x40000000001b60d0
r41            0xe0020000006abae0	0xe0020000006abae0
r42            0xc00000000000038b	0xc00000000000038b
r43            0x0	0x0
r44            0x0	0x0
r45            0x0	0x0
r46            0x0	0x0
r47            0x0	0x0
r48            0x0	0x0
r49            0x0	0x0
r50            0x0	0x0
r51            0x0	0x0
r52            0x0	0x0
r53            0x0	0x0
r54            0x0	0x0
r55            0x0	0x0
r56            0x0	0x0
r57            0x0	0x0
r58            0x0	0x0
r59            0x0	0x0
r60            0x0	0x0
r61            0x0	0x0
r62            0x0	0x0
r63            0x0	0x0
r64            0x0	0x0
r65            0x0	0x0
r66            0x0	0x0
r67            0x0	0x0
r68            0x0	0x0
r69            0x0	0x0
r70            0x0	0x0
r71            0x0	0x0
r72            0x0	0x0
r73            0x0	0x0
r74            0x0	0x0
r75            0x0	0x0
r76            0x0	0x0
r77            0x0	0x0
r78            0x0	0x0
r79            0x0	0x0
r80            0x0	0x0
r81            0x0	0x0
r82            0x0	0x0
r83            0x0	0x0
r84            0x0	0x0
r85            0x0	0x0
r86            0x0	0x0
r87            0x0	0x0
r88            0x0	0x0
r89            0x0	0x0
r90            0x0	0x0
r91            0x0	0x0
r92            0x0	0x0
r93            0x0	0x0
r94            0x0	0x0
r95            0x0	0x0
r96            0x0	0x0
r97            0x0	0x0
r98            0x0	0x0
r99            0x0	0x0
r100           0x0	0x0
r101           0x0	0x0
r102           0x0	0x0
r103           0x0	0x0
r104           0x0	0x0
r105           0x0	0x0
r106           0x0	0x0
r107           0x0	0x0
r108           0x0	0x0
r109           0x0	0x0
r110           0x0	0x0
r111           0x0	0x0
r112           0x0	0x0
r113           0x0	0x0
r114           0x0	0x0
r115           0x0	0x0
r116           0x0	0x0
r117           0x0	0x0
r118           0x0	0x0
r119           0x0	0x0
r120           0x0	0x0
r121           0x0	0x0
r122           0x0	0x0
r123           0x0	0x0
r124           0x0	0x0
r125           0x0	0x0
r126           0x0	0x0
r127           0x0	0x0
p0             0x1	0x1
p1             0x0	0x0
p2             0x0	0x0
p3             0x0	0x0
p4             0x0	0x0
p5             0x0	0x0
p6             0x0	0x0
p7             0x1	0x1
p8             0x0	0x0
p9             0x1	0x1
p10            0x1	0x1
p11            0x0	0x0
p12            0x0	0x0
p13            0x1	0x1
p14            0x1	0x1
p15            0x0	0x0
p16            0x0	0x0
p17            0x0	0x0
p18            0x0	0x0
p19            0x0	0x0
p20            0x0	0x0
p21            0x0	0x0
p22            0x0	0x0
p23            0x0	0x0
p24            0x0	0x0
p25            0x0	0x0
p26            0x0	0x0
p27            0x0	0x0
p28            0x0	0x0
p29            0x0	0x0
p30            0x0	0x0
p31            0x0	0x0
p32            0x0	0x0
p33            0x0	0x0
p34            0x0	0x0
p35            0x0	0x0
p36            0x0	0x0
p37            0x0	0x0
p38            0x0	0x0
p39            0x0	0x0
p40            0x0	0x0
p41            0x0	0x0
p42            0x0	0x0
p43            0x0	0x0
p44            0x0	0x0
p45            0x0	0x0
p46            0x0	0x0
p47            0x0	0x0
p48            0x0	0x0
p49            0x0	0x0
p50            0x0	0x0
p51            0x0	0x0
p52            0x0	0x0
p53            0x0	0x0
p54            0x0	0x0
p55            0x0	0x0
p56            0x0	0x0
p57            0x0	0x0
p58            0x0	0x0
p59            0x0	0x0
p60            0x0	0x0
p61            0x0	0x0
p62            0x0	0x0
p63            0x0	0x0
b0             0x400000000006d240	0x400000000006d240
b1             0x0	0x0
b2             0x0	0x0
b3             0x0	0x0
b4             0x0	0x0
b5             0x0	0x0
b6             0x410005801a415000	0x410005801a415000
b7             0x0	0x0
vfp            0x80000fffffffb360	0x80000fffffffb360
vrap           0x0	0x0
pr             0x6681	0x6681
ip             0x400000000006d312	0x400000000006d312
psr            0x40000000010	0x40000000010
cfm            0x38b	0x38b
kr0            0x0	0x0
kr1            0x0	0x0
kr2            0x0	0x0
kr3            0x0	0x0
kr4            0x0	0x0
kr5            0x0	0x0
kr6            0x0	0x0
kr7            0x0	0x0
rsc            0xf	0xf
bsp            0x80000fff80000178	0x80000fff80000178
bspstore       0x80000fff800000c8	0x80000fff800000c8
rnat           0x0	0x0
fcr            0x0	0x0
eflag          0x0	0x0
csd            0x0	0x0
ssd            0x0	0x0
cflg           0x0	0x0
fsr            0x0	0x0
fir            0x0	0x0
fdr            0x0	0x0
ccv            0x0	0x0
unat           0x0	0x0
fpsr           0x9804c8a70033f	0x9804c8a70033f
itc            0x0	0x0
pfs            0xc00000000000038b	0xc00000000000038b
lc             0x0	0x0
ec             0x0	0x0
nat0           0x0	0x0
nat1           0x0	0x0
nat2           0x0	0x0
nat3           0x0	0x0
nat4           0x0	0x0
nat5           0x0	0x0
nat6           0x0	0x0
nat7           0x0	0x0
nat8           0x0	0x0
nat9           0x0	0x0
nat10          0x0	0x0
nat11          0x0	0x0
nat12          0x0	0x0
nat13          0x0	0x0
nat14          0x0	0x0
nat15          0x0	0x0
nat16          0x0	0x0
nat17          0x0	0x0
nat18          0x0	0x0
nat19          0x0	0x0
nat20          0x0	0x0
nat21          0x0	0x0
nat22          0x0	0x0
nat23          0x0	0x0
nat24          0x0	0x0
nat25          0x0	0x0
nat26          0x0	0x0
nat27          0x0	0x0
nat28          0x0	0x0
nat29          0x0	0x0
nat30          0x0	0x0
nat31          0x0	0x0
nat32          0x0	0x0
nat33          0x0	0x0
nat34          0x0	0x0
nat35          0x0	0x0
nat36          0x0	0x0
nat37          0x0	0x0
nat38          0x0	0x0
nat39          0x0	0x0
nat40          0x0	0x0
nat41          0x0	0x0
nat42          0x0	0x0
nat43          0x0	0x0
nat44          0x0	0x0
nat45          0x0	0x0
nat46          0x0	0x0
nat47          0x0	0x0
nat48          0x0	0x0
nat49          0x0	0x0
nat50          0x0	0x0
nat51          0x0	0x0
nat52          0x0	0x0
nat53          0x0	0x0
nat54          0x0	0x0
nat55          0x0	0x0
nat56          0x0	0x0
nat57          0x0	0x0
nat58          0x0	0x0
nat59          0x0	0x0
nat60          0x0	0x0
nat61          0x0	0x0
nat62          0x0	0x0
nat63          0x0	0x0
nat64          0x0	0x0
nat65          0x0	0x0
nat66          0x0	0x0
nat67          0x0	0x0
nat68          0x0	0x0
nat69          0x0	0x0
nat70          0x0	0x0
nat71          0x0	0x0
nat72          0x0	0x0
nat73          0x0	0x0
nat74          0x0	0x0
nat75          0x0	0x0
nat76          0x0	0x0
nat77          0x0	0x0
nat78          0x0	0x0
nat79          0x0	0x0
nat80          0x0	0x0
nat81          0x0	0x0
nat82          0x0	0x0
nat83          0x0	0x0
nat84          0x0	0x0
nat85          0x0	0x0
nat86          0x0	0x0
nat87          0x0	0x0
nat88          0x0	0x0
nat89          0x0	0x0
nat90          0x0	0x0
nat91          0x0	0x0
nat92          0x0	0x0
nat93          0x0	0x0
nat94          0x0	0x0
nat95          0x0	0x0
nat96          0x0	0x0
nat97          0x0	0x0
nat98          0x0	0x0
nat99          0x0	0x0
nat100         0x0	0x0
nat101         0x0	0x0
nat102         0x0	0x0
nat103         0x0	0x0
nat104         0x0	0x0
nat105         0x0	0x0
nat106         0x0	0x0
nat107         0x0	0x0
nat108         0x0	0x0
nat109         0x0	0x0
nat110         0x0	0x0
nat111         0x0	0x0
nat112         0x0	0x0
nat113         0x0	0x0
nat114         0x0	0x0
nat115         0x0	0x0
nat116         0x0	0x0
nat117         0x0	0x0
nat118         0x0	0x0
nat119         0x0	0x0
nat120         0x0	0x0
nat121         0x0	0x0
nat122         0x0	0x0
nat123         0x0	0x0
nat124         0x0	0x0
nat125         0x0	0x0
nat126         0x0	0x0
nat127         0x0	0x0
(gdb)=20





> SUMMARY:
>=20
> 	Keith Owens just pointed out that ia64 function descriptor assignments M=
UST be cast:
>=20
> 		 pointer =3D ((unsigned long *)(&my_printf))[0])
>=20
> 	howerver it appears that other platforms MUST NOT be cast.
>=20
> I was wondering if that a good idea. It seems it might require hacking=20
> a lot of existing code.
>=20
> Why is this necessary for just ia64?=20
>=20
> I've used pointers to functions a lot in the past and I don't recall
> ever haveing a problem like this.
>=20
> See details below...
>=20
> -piet
>=20
> On Thu, Jan 03, 2002 at 02:30:04PM +1100, Keith Owens wrote:
> > On Wed, 2 Jan 2002 16:27:14 -0800,=20
> > Piet/Pete Delaney <piet@sgi.com> wrote:
> > >#include <stdio.h>
> > >
> > >
> > >typedef struct disassemble_info {
> > >        void (*fprintf_func)();
> > >} disassemble_info_t;
> > >
> > >disassemble_info_t disinfo;
> > >
> > >void my_printf(void)
> > >{
> > >        (void) printf("Hello World\n");
> > >}
> > >
> > >main(void)
> > >{
> > >        disinfo.fprintf_func =3D my_printf;
> > >        printf("my_printf is at 0x%llx.\n", my_printf);
> > >        printf("disinfo is at 0x%llx.\n", &disinfo);
> > >        disinfo.fprintf_func();
> > >}
> >=20
> > You are printing the address of the ia64 function descriptor, not the
> > function itself.
> >=20
> >         printf("&my_printf is at 0x%llx.\n", &my_printf);
> > 	printf("my_printf is at 0x%llx.\n", ((unsigned long *)(&my_printf))[0]=
);
> >=20
> > &my_printf is at 0x40000000000009f0.
> > my_printf is at 0x4000000000000690.
> > disinfo is at 0x6000000000000dd8.
> > Hello World
> >=20
> > (gdb) disassemble my_printf
> > Dump of assembler code for function my_printf:
> > 0x4000000000000690 <my_printf>: [MII]       alloc r34=3Dar.pfs,5,4,0
> > 0x4000000000000691 <my_printf+1>:                   mov r35=3Dr12
> > 0x4000000000000692 <my_printf+2>:                   mov r33=B0 >=20
> > (gdb) disassemble 0x4000000000000690=20
> > Dump of assembler code for function my_printf:=20
> > 0x4000000000000690 <my_printf>: [MII]       alloc r34=3Dar.pfs,5,4,0=20
> > 0x4000000000000691 <my_printf+1>:                   mov r35=3Dr12=20
> > 0x4000000000000692 <my_printf+2>:                   mov r33=B0 > >=20
>=20
> Looks like you appear to be right!=20
>=20
> I wonder if this is a problem with src backward compatabity for the C com=
piler
> to make the cast:
>=20
> 	 ((unsigned long *)(&my_printf))[0])
>=20
> need for ia64 but not allowed for irix and ia32.
>=20
>  It would/will require #ifdef's or some architecture specific handeling. =

> That doesn't seem like a fantastic idea if we can avoid it.=20
>=20
>=20
> In the test below you can see that the casting does in fact 'fix'
> the problem on ia64 but it breaks irix and ia32. ia32 seems a=20
> bit brooken allready, the upper bits of the address were wrong.
> Perhaps that's 'just' a printf problem due to it being a 32bit arch.
>=20
> I wonder what the 64 bit SPARC linux port does. I only have a 32 bit
> SPARC linux at home.
>=20
> Why does ia64 require this casting?
>=20
> -piet
>=20
>=20
> ------------------------------------------------------------------
> #include <stdio.h>
>=20
>=20
> typedef struct disassemble_info {
>         void (*fprintf_func)();
> } disassemble_info_t;
>=20
> disassemble_info_t disinfo;
>=20
> void my_printf(void)
> {
>         (void) printf("Hello World\n");
> }
>=20
> main(void)
> {
>         disinfo.fprintf_func =3D my_printf;
>         printf("my_printf is at 0x%llx.\n",   my_printf);
>         printf("&my_printf is at 0x%llx.\n", &my_printf);
> 	printf("&my_printf[0] is at 0x%llx.\n", ((unsigned long *)(&my_printf))[=
0]);=09
>         printf("disinfo is at 0x%llx.\n", &disinfo);
>         disinfo.fprintf_func();
> }
> ------------------------------------------------------------------
>=20
>=20
> ------------------------------------------------------------------
> 			irix
> ------------------------------------------------------------------
>  268 piet1 20:43 /tmp> gcc test.c
>  269 piet1 20:43 /tmp> gdb a.out
> GNU gdb 5.0
> Copyright 2000 Free Software Foundation, Inc.
> GDB is free software, covered by the GNU General Public License, and you =
are
> welcome to change it and/or distribute copies of it under certain conditi=
ons.
> Type "show copying" to see the conditions.
> There is absolutely no warranty for GDB.  Type "show warranty" for detail=
s.
> This GDB was configured as "mips-sgi-irix6.2"...
> (gdb) run
> Starting program: /tmp/a.out
> my_printf is at 0x10000fd0.
> &my_printf is at 0x10000fd0.
> &my_printf[0] is at 0x27bdffd0.			<<-- casting breaks irix ports
> disinfo is at 0x100143e0.
> Hello World
>=20
> Program exited with code 014.
> Current language:  auto; currently asm
> (gdb) disassemble my_printf
> Dump of assembler code for function my_printf:
> 0x10000fd0 <my_printf>: addiu   $sp,$sp,-48
> 0x10000fd4 <my_printf+4>:       sd      $ra,32($sp)
> 0x10000fd8 <my_printf+8>:       sd      $s8,24($sp)
> 0x10000fdc <my_printf+12>:      sd      $gp,16($sp)
> 0x10000fe0 <my_printf+16>:      move    $s8,$sp
> 0x10000fe4 <my_printf+20>:      lui     $at,0x2
> 0x10000fe8 <my_printf+24>:      addiu   $at,$at,-19696
> 0x10000fec <my_printf+28>:      daddu   $gp,$at,$t9
> 0x10000ff0 <my_printf+32>:      lw      $a0,-32720($gp)
> 0x10000ff4 <my_printf+36>:      daddiu  $a0,$a0,16504
> 0x10000ff8 <my_printf+40>:      lw      $t9,-32692($gp)
> 0x10000ffc <my_printf+44>:      jalr    $t9
> 0x10001000 <my_printf+48>:      nop
> 0x10001004 <my_printf+52>:      move    $sp,$s8
> 0x10001008 <my_printf+56>:      ld      $ra,32($sp)
> 0x1000100c <my_printf+60>:      ld      $s8,24($sp)
> 0x10001010 <my_printf+64>:      ld      $gp,16($sp)
> 0x10001014 <my_printf+68>:      addiu   $sp,$sp,48
> 0x10001018 <my_printf+72>:      jr      $ra
> 0x1000101c <my_printf+76>:      nop
> End of assembler dump.
> (gdb)
> ------------------------------------------------------------------
>=20
>=20
> ------------------------------------------------------------------
> 			ia32 linux
> ------------------------------------------------------------------
>  296 piet2 14:34 ~/src> gcc test.c
>  297 piet2 14:34 ~/src> gdb a.out
> GNU gdb 5.1
> Copyright 2001 Free Software Foundation, Inc.
> GDB is free software, covered by the GNU General Public License, and you =
are
> welcome to change it and/or distribute copies of it under certain conditi=
ons.
> Type "show copying" to see the conditions.
> There is absolutely no warranty for GDB.  Type "show warranty" for detail=
s.
> This GDB was configured as "i686-pc-linux-gnu"...
> (gdb) run
> Starting program: /home/piet/src/a.out
> ~piet/.cshrc: Entry
> ~piet/.cshrc: Non Interactive Shell
> ~piet/.cshrc: Not Interactive shlvl: 5
> my_printf is at 0xbffff8e808048460.		<<----- ia32 linux high order bits a=
re wrong.=20
> &my_printf is at 0xbffff8e808048460.
> &my_printf[0] is at 0xbffff8e883e58955.		<<----- casting breaks ia32 linu=
x ports
> disinfo is at 0xbffff8e8080496f4.
> Hello World
>=20
> Program exited with code 014.
> (gdb) disassemble my_printf
> Dump of assembler code for function my_printf:
> 0x8048460 <my_printf>:  push   %ebp
> 0x8048461 <my_printf+1>:        mov    %esp,%ebp
> 0x8048463 <my_printf+3>:        sub    $0x8,%esp
> 0x8048466 <my_printf+6>:        sub    $0xc,%esp
> 0x8048469 <my_printf+9>:        push   $0x8048558
> 0x804846e <my_printf+14>:       call   0x804833c <printf>
> 0x8048473 <my_printf+19>:       add    $0x10,%esp
> 0x8048476 <my_printf+22>:       leave
> 0x8048477 <my_printf+23>:       ret
> End of assembler dump.
> (gdb)
> ------------------------------------------------------------------
>=20
>=20
> ------------------------------------------------------------------
> 			ia64 linux
> ------------------------------------------------------------------
>  260 monica 20:27 ~/src> gcc test.c
>  261 monica 20:27 ~/src> gdb a.out
> GNU gdb Red Hat Linux 7.x (5.0rh-9)
> Copyright 2001 Free Software Foundation, Inc.
> GDB is free software, covered by the GNU General Public License, and you =
are
> welcome to change it and/or distribute copies of it under certain conditi=
ons.
> Type "show copying" to see the conditions.
> There is absolutely no warranty for GDB.  Type "show warranty" for detail=
s.
> This GDB was configured as "ia64-redhat-linux"...
> (gdb) run
> Starting program: /home/piet/src/a.out
> ~piet/.cshrc: Entry
> ~piet/.cshrc: Non Interactive Shell
> ~piet/.cshrc: Not Interactive shlvl: 2
> my_printf is at 0x4000000000000880.
> &my_printf is at 0x4000000000000880.
> &my_printf[0] is at 0x4000000000000560.
> disinfo is at 0x6000000000000ba8.
> Hello World
>=20
> Program exited with code 014.
> (gdb) disassemble my_printf
> Dump of assembler code for function my_printf:
> 0x4000000000000560 <my_printf>: 	[MII]       alloc r34=3Dar.pfs,5,4,0
> 0x4000000000000561 <my_printf+1>:                   mov r35=3Dr12
> 0x4000000000000562 <my_printf+2>:                   mov r33=B0
> 0x4000000000000570 <my_printf+16>:      [MMI]       addl r14=80,r1;;
> 0x4000000000000571 <my_printf+17>:                  ld8 r36=3D[r14]
> 0x4000000000000572 <my_printf+18>:                  mov r32=3Dr1
> 0x4000000000000580 <my_printf+32>:      [MFB]       nop.m 0x0
> 0x4000000000000581 <my_printf+33>:                  nop.f 0x0
> 0x4000000000000582 <my_printf+34>:                  br.call.sptk.many b0=
=3D0x4000000000000400 <_init+272>;;
> 0x4000000000000590 <my_printf+48>:      [MII]       mov r1=3Dr32
> 0x4000000000000591 <my_printf+49>:                  mov.i ar.pfs=3Dr34
> 0x4000000000000592 <my_printf+50>:                  mov b0=3Dr33
> 0x40000000000005a0 <my_printf+64>:      [MFB]       mov r12=3Dr35
> 0x40000000000005a1 <my_printf+65>:                  nop.f 0x0
> 0x40000000000005a2 <my_printf+66>:                  br.ret.sptk.many b0;;
> End of assembler dump.
> (gdb)
> ------------------------------------------------------------------
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

