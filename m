From: Martin Pool <mbp@sourcefrog.net>
Date: Wed, 29 Oct 2003 03:42:15 +0000
Subject: Re: show_mem panics in 2.4.22
Message-Id: <marc-linux-ia64-106739900411931@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106731898417513@msgid-missing>
In-Reply-To: <marc-linux-ia64-106731898417513@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On 28 Oct 2003, John Marvin <jsm@udlkern.fc.hp.com> wrote:
> > I'm running linux-2.4.22-ia64-030909 on an rx2600.  The show_mem()
> > function always causes a kernel panic.  This is reached when you send
> > 'SysRq m' or serial 'BREAK m' to find out about used memory, etc.
> >
> > The problem seems to be that this function is written assuming that
> > the discontiguous memory scheme is used, but that's not the case in my
> > configuration.  I see that in 2.6.0-test8 there are two versions of
> > the function for the contig/discontig cases.  The crash is on the line
> > that reads through pgdat->node_mem_map.  I'm not sure exactly what is
> > wrong with that.
>=20
>=20
> I'm not sure why this just started to show up. The problem is that
> the size of struct page doesn't divide into the page size evenly, so
> the structure overlaps holes in the mem_map array. Here is a fix,
> but I am still not sure of the performance implications (extra memory
> dereference). There may be a better fix, although not as simple, if
> this has performance implications.

I'm sorry to say this does not seem to fix it.  Here's the trace
information, plus some printks I added.

The trap occurs when reading 0x30 =3D 48 bytes after the start of the
node_mem_map.

I'll try to get some more information.

-----
SysRq : Show Memory
Mem-info:
Free pages:      4001312kB (     0kB HighMem)
Zone:DMA freepages:964848kB min:  4080kB low:  8160kB high: 12240kB
Zone:Normal freepages:3036464kB min:  4080kB low:  8160kB high: 12240kB
Zone:HighMem freepages:     0kB min:     0kB low:     0kB high:     0kB
( Active: 835, inactive: 732, free: 250082 )
Hello! Got to here
1*16kB 3*32kB 0*64kB 3*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 3*4096kB 0*8=
192kB 2*16384kB 2*32768kB 1*65536kB 2*131072kB 2*262144kB 0*524288kB 0*1048=
576kB 0*2097152kB 0*4194304kB =3D 964848kB)
1*16kB 1*32kB 0*64kB 0*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 1*4096kB 0*8=
192kB 1*16384kB 0*32768kB 2*65536kB 2*131072kB 2*262144kB 2*524288kB 1*1048=
576kB 0*2097152kB 0*4194304kB =3D 3036464kB)
=3D 0kB)
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap:       4095968kB
pgdat at e000000004a7aab8
node_mem_map is at a0007fffa6a00000
node_size is 256848
Unable to handle kernel paging request at virtual address a0007fffa6a00030
swapper[0]: Oops 11012296146944
                                                                           =
    =20
Pid: 0, CPU 1, comm:              swapper
psr : 0000121008026038 ifs : 8000000000000e20 ip  : [<e000000004443481>]   =
 Not tainted
ip is at (no symbol)
unat: 0000000000000000 pfs : 0000000000000e20 rsc : 0000000000000003
rnat: e000000004b81bb4 bsps: c0000000f4050000 pr  : 80000000ff605965
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : e000000004443420 b6  : e000000004403310 b7  : e000000004677fa0
f6  : 0fffbccccccccc8c00000 f7  : 0ffdaa200000000000000
f8  : 100008000000000000000 f9  : 10002a000000000000000
f10 : 0fffcccccccccc8c00000 f11 : 1003e0000000000000000
r1  : e000000004c6ea80 r2  : e000000004a78bf8 r3  : 0000000000000000
r8  : 0000000000000014 r9  : 0000000000000000 r10 : e0000040436f8000
r11 : e0000040436ffe28 r12 : e0000040fef87c40 r13 : e0000040fef80000
r14 : 0000000000000001 r15 : 0000000000000000 r16 : 0000000000000000
r17 : e0000040436ffe30 r18 : 0000000000004000 r19 : 0000000000004000
r20 : 0000000000000000 r21 : e000000004b81b1c r22 : 000000000003eb50
r23 : 2e8ba2e8ba2e8ba3 r24 : 0000000000000060 r25 : 0000000000000fff
r26 : 0000000000ffffff r27 : 0000000000800000 r28 : e000000004b81b1c
r29 : 0000000000000001 r30 : a0007fffa6a00030 r31 : a0007fffa6a00000

Call Trace:
 [<e000000004414be0>] (no symbol)
                                sp=E0000040fef87810 bsp=E0000040fef811c8
 [<e0000000044221c0>] (no symbol)
                                sp=E0000040fef879e0 bsp=E0000040fef81190
 [<e0000000044452b0>] (no symbol)
                                sp=E0000040fef879e0 bsp=E0000040fef81130
 [<e00000000440e6a0>] (no symbol)
                                sp=E0000040fef87a70 bsp=E0000040fef81130
 [<e000000004443480>] (no symbol)
                                sp=E0000040fef87c40 bsp=E0000040fef81050
 <0>Kernel panic: Aiee, killing interrupt handler!

Trace; e000000004414be0 <show_stack+80/a0>
Trace; e0000000044221c0 <die+160/200>
Trace; e0000000044452b0 <ia64_do_page_fault+330/a80>
Trace; e00000000440e6a0 <ia64_leave_kernel+0/2a0>
Trace; e000000004443480 <show_mem+220/4c0>

In interrupt handler - not syncing
-----

--=20
Martin=20
