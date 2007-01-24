From: "JWM" <jwm@systemfabricworks.com>
Date: Wed, 24 Jan 2007 16:55:12 +0000
Subject: Spinlock bug??
Message-Id: <003e01c73fd8$6a46f730$7401a8c0@Maelstrom>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

    Hi all;
    I'm working on a Bull - 8 way ia64 system running a RedHat variant of=20
2.6.17.
    I keep getting a spin lock bug and dump , attached.
    It appears that cpuset_set_cpus_affinity is taking doing a task_lock on=
=20
the task structure and only releaseing it after the cpu has changed. That=20
naturally causes the spin_bug function to get upset.
    The lock doesn't appear to be required since set_cpus_allowed makes sur=
e=20
that things are serialized pretty well.
    Am I missing something here or is this lock not required.

    ....JW
    ___________________________________________DUMP________________________=
_______________________
    Jan 22 20:40:14 Itanium-2 kernel: BUG: spinlock wrong CPU on CPU#0,=20
process1/13439
Jan 22 20:40:14 Itanium-2 kernel:  lock: e000000454a00e08, .magic: dead4ead=
,=20
.owner: process1/13439, .owner_cpu: 4
Jan 22 20:40:14 Itanium-2 kernel:
Jan 22 20:40:14 Itanium-2 kernel: Call Trace:
Jan 22 20:40:14 Itanium-2 kernel:  [<a000000100010da0>] show_stack+0x80/0xa0
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a07c50 bsp=E000000454a01190
Jan 22 20:40:14 Itanium-2 kernel:  [<a000000100010df0>] dump_stack+0x30/0x60
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a07e20 bsp=E000000454a01178
Jan 22 20:40:14 Itanium-2 kernel:     r32 : a0000001002b4980 r33 :=20
000000000000028b r34 : 00000000dead4ead
Jan 22 20:40:14 Itanium-2 kernel:  [<a0000001002b4980>] spin_bug+0x100/0x120
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a07e20 bsp=E000000454a01150
Jan 22 20:40:14 Itanium-2 kernel:     r32 : e000000454a00e08 r33 :=20
e000000454a00000 r34 : a0000001002b4d10
Jan 22 20:40:14 Itanium-2 kernel:     r35 : 0000000000000308 r36 :=20
0000000000200200
Jan 22 20:40:14 Itanium-2 kernel:  [<a0000001002b4d10>]=20
_raw_spin_unlock+0xd0/0x120
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a07e20 bsp=E000000454a01120
Jan 22 20:40:14 Itanium-2 kernel:     r32 : e000000454a00e08 r33 :=20
e000000454a00e10 r34 : e000000454a00e18
Jan 22 20:40:14 Itanium-2 kernel:     r35 : a00000010053c560 r36 :=20
0000000000000205 r37 : a0000001000c42c0
Jan 22 20:40:14 Itanium-2 kernel:  [<a00000010053c560>]=20
_spin_unlock+0x20/0x40
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a07e20 bsp=E000000454a01100
Jan 22 20:40:14 Itanium-2 kernel:     r32 : e000000454a00e08 r33 :=20
a0000001000c42d0 r34 : 0000000000000308
Jan 22 20:40:14 Itanium-2 kernel:     r35 : e000000100004b18
Jan 22 20:40:14 Itanium-2 kernel:  [<a0000001000c42d0>]=20
cpuset_set_cpus_affinity+0x110/0x160
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a07e20 bsp=E000000454a010d0
Jan 22 20:40:14 Itanium-2 kernel:     r32 : 0000000000000000 r33 :=20
0000000000000001 r34 : e000000454a00e08
Jan 22 20:40:14 Itanium-2 kernel:     r35 : a0000001000655f0 r36 :=20
0000000000000389 r37 : a00000010053c5e0
Jan 22 20:40:14 Itanium-2 kernel:  [<a0000001000655f0>]=20
sched_setaffinity+0x110/0x1e0
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a07e20 bsp=E000000454a01098
Jan 22 20:40:14 Itanium-2 kernel:     r32 : e000000454a00000 r33 :=20
0000000000000001 r34 : e000000454a00010
Jan 22 20:40:14 Itanium-2 kernel:     r35 : ffffffffffffffff r36 :=20
a0000001000657a0 r37 : 000000000000060f
Jan 22 20:40:14 Itanium-2 kernel:     r38 : 0000000000000000
Jan 22 20:40:14 Itanium-2 kernel:  [<a0000001000657a0>]=20
sys_sched_setaffinity+0xe0/0x100
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a07e20 bsp=E000000454a01038
Jan 22 20:40:14 Itanium-2 kernel:     r32 : 0000000000000000 r33 :=20
0000000000000080 r34 : 6000000fffcffe40
Jan 22 20:40:14 Itanium-2 kernel:     r35 : 0000000000000000 r36 :=20
2000000000267ab0 r37 : 20000000004168b0
Jan 22 20:40:14 Itanium-2 kernel:     r38 : 2000000000019280 r39 :=20
c000000000000711 r40 : 0000000000000000
Jan 22 20:40:14 Itanium-2 kernel:     r41 : a00000010000b640 r42 :=20
0000000000000008 r43 : 0000000000000000
Jan 22 20:40:14 Itanium-2 kernel:  [<a00000010000b640>]=20
ia64_ret_from_syscall+0x0/0x20
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a07e30 bsp=E000000454a01038
Jan 22 20:40:14 Itanium-2 kernel:  [<a000000000010640>]=20
__kernel_syscall_via_break+0x0/0x20
Jan 22 20:40:14 Itanium-2 kernel:=20
sp=E000000454a08000 bsp=E000000454a01038

