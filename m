From: Piet/Pete Delaney <piet@sgi.com>
Date: Thu, 03 Jan 2002 05:46:35 +0000
Subject: [Linux-ia64] is casting of function descriptor assignments for ia64 ONLY a good idea?
Message-Id: <marc-linux-ia64-105590698805732@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

SUMMARY:

	Keith Owens just pointed out that ia64 function descriptor assignments MUS=
T be cast:

		 pointer =3D ((unsigned long *)(&my_printf))[0])

	howerver it appears that other platforms MUST NOT be cast.

I was wondering if that a good idea. It seems it might require hacking=20
a lot of existing code.

Why is this necessary for just ia64?=20

I've used pointers to functions a lot in the past and I don't recall
ever haveing a problem like this.

See details below...

-piet

On Thu, Jan 03, 2002 at 02:30:04PM +1100, Keith Owens wrote:
> On Wed, 2 Jan 2002 16:27:14 -0800,=20
> Piet/Pete Delaney <piet@sgi.com> wrote:
> >#include <stdio.h>
> >
> >
> >typedef struct disassemble_info {
> >        void (*fprintf_func)();
> >} disassemble_info_t;
> >
> >disassemble_info_t disinfo;
> >
> >void my_printf(void)
> >{
> >        (void) printf("Hello World\n");
> >}
> >
> >main(void)
> >{
> >        disinfo.fprintf_func =3D my_printf;
> >        printf("my_printf is at 0x%llx.\n", my_printf);
> >        printf("disinfo is at 0x%llx.\n", &disinfo);
> >        disinfo.fprintf_func();
> >}
>=20
> You are printing the address of the ia64 function descriptor, not the
> function itself.
>=20
>         printf("&my_printf is at 0x%llx.\n", &my_printf);
> 	printf("my_printf is at 0x%llx.\n", ((unsigned long *)(&my_printf))[0]);
>=20
> &my_printf is at 0x40000000000009f0.
> my_printf is at 0x4000000000000690.
> disinfo is at 0x6000000000000dd8.
> Hello World
>=20
> (gdb) disassemble my_printf
> Dump of assembler code for function my_printf:
> 0x4000000000000690 <my_printf>: [MII]       alloc r34=3Dar.pfs,5,4,0
> 0x4000000000000691 <my_printf+1>:                   mov r35=3Dr12
> 0x4000000000000692 <my_printf+2>:                   mov r33=B0 >=20
> (gdb) disassemble 0x4000000000000690=20
> Dump of assembler code for function my_printf:=20
> 0x4000000000000690 <my_printf>: [MII]       alloc r34=3Dar.pfs,5,4,0=20
> 0x4000000000000691 <my_printf+1>:                   mov r35=3Dr12=20
> 0x4000000000000692 <my_printf+2>:                   mov r33=B0 > >=20

Looks like you appear to be right!=20

I wonder if this is a problem with src backward compatabity for the C compi=
ler
to make the cast:

	 ((unsigned long *)(&my_printf))[0])

need for ia64 but not allowed for irix and ia32.

 It would/will require #ifdef's or some architecture specific handeling.=20
That doesn't seem like a fantastic idea if we can avoid it.=20


In the test below you can see that the casting does in fact 'fix'
the problem on ia64 but it breaks irix and ia32. ia32 seems a=20
bit brooken allready, the upper bits of the address were wrong.
Perhaps that's 'just' a printf problem due to it being a 32bit arch.

I wonder what the 64 bit SPARC linux port does. I only have a 32 bit
SPARC linux at home.

Why does ia64 require this casting?

-piet


------------------------------------------------------------------
#include <stdio.h>


typedef struct disassemble_info {
        void (*fprintf_func)();
} disassemble_info_t;

disassemble_info_t disinfo;

void my_printf(void)
{
        (void) printf("Hello World\n");
}

main(void)
{
        disinfo.fprintf_func =3D my_printf;
        printf("my_printf is at 0x%llx.\n",   my_printf);
        printf("&my_printf is at 0x%llx.\n", &my_printf);
	printf("&my_printf[0] is at 0x%llx.\n", ((unsigned long *)(&my_printf))[0]=
);=09
        printf("disinfo is at 0x%llx.\n", &disinfo);
        disinfo.fprintf_func();
}
------------------------------------------------------------------


------------------------------------------------------------------
			irix
------------------------------------------------------------------
 268 piet1 20:43 /tmp> gcc test.c
 269 piet1 20:43 /tmp> gdb a.out
GNU gdb 5.0
Copyright 2000 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain condition=
s.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "mips-sgi-irix6.2"...
(gdb) run
Starting program: /tmp/a.out
my_printf is at 0x10000fd0.
&my_printf is at 0x10000fd0.
&my_printf[0] is at 0x27bdffd0.			<<-- casting breaks irix ports
disinfo is at 0x100143e0.
Hello World

Program exited with code 014.
Current language:  auto; currently asm
(gdb) disassemble my_printf
Dump of assembler code for function my_printf:
0x10000fd0 <my_printf>: addiu   $sp,$sp,-48
0x10000fd4 <my_printf+4>:       sd      $ra,32($sp)
0x10000fd8 <my_printf+8>:       sd      $s8,24($sp)
0x10000fdc <my_printf+12>:      sd      $gp,16($sp)
0x10000fe0 <my_printf+16>:      move    $s8,$sp
0x10000fe4 <my_printf+20>:      lui     $at,0x2
0x10000fe8 <my_printf+24>:      addiu   $at,$at,-19696
0x10000fec <my_printf+28>:      daddu   $gp,$at,$t9
0x10000ff0 <my_printf+32>:      lw      $a0,-32720($gp)
0x10000ff4 <my_printf+36>:      daddiu  $a0,$a0,16504
0x10000ff8 <my_printf+40>:      lw      $t9,-32692($gp)
0x10000ffc <my_printf+44>:      jalr    $t9
0x10001000 <my_printf+48>:      nop
0x10001004 <my_printf+52>:      move    $sp,$s8
0x10001008 <my_printf+56>:      ld      $ra,32($sp)
0x1000100c <my_printf+60>:      ld      $s8,24($sp)
0x10001010 <my_printf+64>:      ld      $gp,16($sp)
0x10001014 <my_printf+68>:      addiu   $sp,$sp,48
0x10001018 <my_printf+72>:      jr      $ra
0x1000101c <my_printf+76>:      nop
End of assembler dump.
(gdb)
------------------------------------------------------------------


------------------------------------------------------------------
			ia32 linux
------------------------------------------------------------------
 296 piet2 14:34 ~/src> gcc test.c
 297 piet2 14:34 ~/src> gdb a.out
GNU gdb 5.1
Copyright 2001 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain condition=
s.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "i686-pc-linux-gnu"...
(gdb) run
Starting program: /home/piet/src/a.out
~piet/.cshrc: Entry
~piet/.cshrc: Non Interactive Shell
~piet/.cshrc: Not Interactive shlvl: 5
my_printf is at 0xbffff8e808048460.		<<----- ia32 linux high order bits are=
 wrong.=20
&my_printf is at 0xbffff8e808048460.
&my_printf[0] is at 0xbffff8e883e58955.		<<----- casting breaks ia32 linux =
ports
disinfo is at 0xbffff8e8080496f4.
Hello World

Program exited with code 014.
(gdb) disassemble my_printf
Dump of assembler code for function my_printf:
0x8048460 <my_printf>:  push   %ebp
0x8048461 <my_printf+1>:        mov    %esp,%ebp
0x8048463 <my_printf+3>:        sub    $0x8,%esp
0x8048466 <my_printf+6>:        sub    $0xc,%esp
0x8048469 <my_printf+9>:        push   $0x8048558
0x804846e <my_printf+14>:       call   0x804833c <printf>
0x8048473 <my_printf+19>:       add    $0x10,%esp
0x8048476 <my_printf+22>:       leave
0x8048477 <my_printf+23>:       ret
End of assembler dump.
(gdb)
------------------------------------------------------------------


------------------------------------------------------------------
			ia64 linux
------------------------------------------------------------------
 260 monica 20:27 ~/src> gcc test.c
 261 monica 20:27 ~/src> gdb a.out
GNU gdb Red Hat Linux 7.x (5.0rh-9)
Copyright 2001 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain condition=
s.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "ia64-redhat-linux"...
(gdb) run
Starting program: /home/piet/src/a.out
~piet/.cshrc: Entry
~piet/.cshrc: Non Interactive Shell
~piet/.cshrc: Not Interactive shlvl: 2
my_printf is at 0x4000000000000880.
&my_printf is at 0x4000000000000880.
&my_printf[0] is at 0x4000000000000560.
disinfo is at 0x6000000000000ba8.
Hello World

Program exited with code 014.
(gdb) disassemble my_printf
Dump of assembler code for function my_printf:
0x4000000000000560 <my_printf>: 	[MII]       alloc r34=3Dar.pfs,5,4,0
0x4000000000000561 <my_printf+1>:                   mov r35=3Dr12
0x4000000000000562 <my_printf+2>:                   mov r33=B0
0x4000000000000570 <my_printf+16>:      [MMI]       addl r14=80,r1;;
0x4000000000000571 <my_printf+17>:                  ld8 r36=3D[r14]
0x4000000000000572 <my_printf+18>:                  mov r32=3Dr1
0x4000000000000580 <my_printf+32>:      [MFB]       nop.m 0x0
0x4000000000000581 <my_printf+33>:                  nop.f 0x0
0x4000000000000582 <my_printf+34>:                  br.call.sptk.many b0=3D=
0x4000000000000400 <_init+272>;;
0x4000000000000590 <my_printf+48>:      [MII]       mov r1=3Dr32
0x4000000000000591 <my_printf+49>:                  mov.i ar.pfs=3Dr34
0x4000000000000592 <my_printf+50>:                  mov b0=3Dr33
0x40000000000005a0 <my_printf+64>:      [MFB]       mov r12=3Dr35
0x40000000000005a1 <my_printf+65>:                  nop.f 0x0
0x40000000000005a2 <my_printf+66>:                  br.ret.sptk.many b0;;
End of assembler dump.
(gdb)
------------------------------------------------------------------

