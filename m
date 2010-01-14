From: Luming Yu <luming.yu@gmail.com>
Date: Thu, 14 Jan 2010 04:03:35 +0000
Subject: Re: lockdep support caused an MCA
Message-Id: <3877989d1001132003k6b739e2ejf9e28ff95a2fff98@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100111195825.GE10162@ldl.fc.hp.com>
In-Reply-To: <20100111195825.GE10162@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Jan 12, 2010 at 9:51 AM, Yu, Luming <luming.yu@intel.com> wrote:
> Let me check if I can get access to an HP rx8640 to re-spin the patch.
>
>
> -----Original Message-----
> From: Alex Chiang [mailto:achiang@hp.com]
> Sent: Tuesday, January 12, 2010 3:58 AM
> To: Yu, Luming; Luck, Tony
> Cc: linux-ia64@vger.kernel.org
> Subject: lockdep support caused an MCA
>
> This patch 2f02b4a12b24c9f077c6d739ac23c9b90840ccca:
>
> Author: Luming Yu <luming.yu@intel.com> =C2=A02009-12-04 09:14:30
>
> =C2=A0 =C2=A0[IA64] lockdep support
>
> =C2=A0 =C2=A0Basic functionality for lockdep on ia64.
>
> =C2=A0 =C2=A0Known issues:
> =C2=A0 =C2=A00. dynamic allocate per CPU area in lockdep.
> =C2=A0 =C2=A01. lock held in leave kernel.
> =C2=A0 =C2=A02. enabling CONFIG_DEBUG_LOCKDEP triggers the lockdep warnin=
g.
> =C2=A0 =C2=A03. Need to implement save_stack functions
> =C2=A0 =C2=A04. Replace some cpp macros with inline functions
> =C2=A0 =C2=A05. Add nmi_enter/nmi_exit
>
> =C2=A0 =C2=A0Signed-off-by: Bob Picco <bob.picco@hp.com>
> =C2=A0 =C2=A0Signed-off-by: Yu Luming <luming.yu@intel.com>
> =C2=A0 =C2=A0Signed-off-by: Tony Luck <tony.luck@intel.com>
>
> causes a very early MCA on an HP rx8640.
>
> Unfortunately, even with early_printk turned on, the machine
> encounters the MCA and reboots before any output occurs, so I
> don't have any further information.
>
> I haven't done any other triage on this as the patch has already
> been dropped from Tony's tree, but I'd be happy to test the next
> go-around.

I have managed to get the patch run on a HP rx8640 system with
latest next tree + ia64-lockdep patch. The following is the part of
boot log with lockdep footprints..The interesting thing is
lockdep code seems to have detected possible recursive locking
with the kernel on the platform.

Kernel command line:
BOOT_IMAGE=3Dscsi0:EFI\redhat\vmlinuz-2.6.33-rc3-next-20100113
root=3D/dev/VolGroup00/LogVol00  ro
PID hash table entries: 4096 (order: 1, 32768 bytes)
Memory: 33235200k/33370096k available (8346k code, 171728k reserved,
10446k data, 2400k init)
Hierarchical RCU implementation.
RCU-based detection of stalled CPUs is enabled.
NR_IRQS:1024

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D[ INFO: p=
ossible recursive locking detected ]
2.6.33-rc3-next-20100113 #1
---------------------------------------------
swapper/0 is trying to acquire lock:
 (&(&parent->list_lock)->rlock){......}, at: [<a0000001001e9450>]
kmem_cache_free+0x2f0/0x560

but task is already holding lock:
 (&(&parent->list_lock)->rlock){......}, at: [<a0000001001ea490>]
kfree+0x470/0x620

other info that might help us debug this:
2 locks held by swapper/0:
 #0:  (cache_chain_mutex){+.+...}, at: [<a000000100acf350>]
kmem_cache_init_late+0x30/0x240
 #1:  (&(&parent->list_lock)->rlock){......}, at: [<a0000001001ea490>]
kfree+0x470/0x620

stack backtrace:

Call Trace:
 [<a000000100015fb0>] show_stack+0x50/0xa0
                                sp=A000000100f07bc0 bsp=A000000100f01ec0
 [<a000000100016030>] dump_stack+0x30/0x60
                                sp=A000000100f07d90 bsp=A000000100f01ea0
 [<a0000001000f3d10>] validate_chain+0x1010/0x2660
                                sp=A000000100f07d90 bsp=A000000100f01e28
 [<a0000001000f6880>] __lock_acquire+0x1520/0x1660
                                sp=A000000100f07de0 bsp=A000000100f01d90
 [<a0000001000f6b50>] lock_acquire+0x190/0x200
                                sp=A000000100f07de0 bsp=A000000100f01d30
 [<a00000010081ba50>] _raw_spin_lock+0x50/0xe0
                                sp=A000000100f07df0 bsp=A000000100f01cf8
 [<a0000001001e9450>] kmem_cache_free+0x2f0/0x560
                                sp=A000000100f07df0 bsp=A000000100f01ca8
 [<a0000001001e97a0>] slab_destroy+0xe0/0x100
                                sp=A000000100f07e00 bsp=A000000100f01c70
 [<a0000001001e9a20>] free_block+0x260/0x2e0
                                sp=A000000100f07e10 bsp=A000000100f01c10
 [<a0000001001ea4b0>] kfree+0x490/0x620
                                sp=A000000100f07e10 bsp=A000000100f01bb8
 [<a0000001001eafb0>] do_tune_cpucache+0x450/0xba0
                                sp=A000000100f07e20 bsp=A000000100f01b40
 [<a0000001001ebbb0>] enable_cpucache+0x110/0x1e0
                                sp=A000000100f07e20 bsp=A000000100f01b08
 [<a000000100acf380>] kmem_cache_init_late+0x60/0x240
                                sp=A000000100f07e20 bsp=A000000100f01ae0
 [<a000000100aa92b0>] start_kernel+0x570/0x980
                                sp=A000000100f07e20 bsp=A000000100f01a60
 [<a0000001007eaa00>] start_ap+0x760/0x780
                                sp=A000000100f07e30 bsp=A000000100f019c0
Console: colour dummy device 80x25
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:  8
... MAX_LOCK_DEPTH:          48
... MAX_LOCKDEP_KEYS:        1023
... CLASSHASH_SIZE:          512
... MAX_LOCKDEP_ENTRIES:     16384
... MAX_LOCKDEP_CHAINS:      32768
... CHAINHASH_SIZE:          16384
 memory used by lock dependency info: 2839 kB
 per task-struct memory footprint: 2688 bytes
----------------------------------
| Locking API testsuite disabled |
----------------------------------

caught one possbile recurive locking
