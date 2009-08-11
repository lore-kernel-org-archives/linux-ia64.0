From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Tue, 11 Aug 2009 18:12:02 +0000
Subject: RE: [RFC PATCH] ia64: convert to dynamic percpu allocator
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8B3A85355@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A65B0AB.5000608@kernel.org>
 <A6AD88C3F2289247BE726C37303E1EB8B097D4C5@orsmsx505.amr.corp.intel.com>
 <4A663DC7.4060600@kernel.org>
 <A6AD88C3F2289247BE726C37303E1EB8B0A9115B@orsmsx505.amr.corp.intel.com>
 <4A695897.2020902@kernel.org>
In-Reply-To: <4A695897.2020902@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: 'Tejun Heo' <tj@kernel.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, 'lkml' <linux-kernel@vger.kernel.org>, "'linux-arch@vger.kernel.org'" <linux-arch@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>

>Yu, Fenghua wrote:
>
>> After cloning from
>> git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git, kernel
>> built with CONFIG_DISCONTIGMEM=3Dy boots ok.
>>
>> After pulling from review-ia64, kernel built with
>> CONFIG_DISCONTIGMEM=3Dy can not boot on ia64. After loading kernel and
>> initrd, system hangs and doesn't show anything on serial port.
>
>Heh, I didn't really expect it to work that easily either.  The code
>builds but is completely untested (I can't test them).  Can you try to
>track it down?  Serial console should be up and running at that point,
>no?
>
>Thanks.

IA64 kernel boots hit this in mm/percpu.c
BUG_ON(ai->unit_size < size_sum);
ai->unit_size is PERCPU_PAGE_SIZE which is 64K on IA64. size_sum is relativ=
ely smaller than 64K.

Will you define PERCPU_DYNAMIC_RESERVE and PERCPU_MODULE_RESERVE as PAGE_SI=
ZE or the bigger one between the current definition and PAGE_SIZE?

Even with the above PAGE_SIZE changes, the kernel still reports warning fro=
m 952: WARN_ON(chunk->immutable) and then panic.

Calibrating delay loop... 1593.34 BogoMIPS (lpj186688)
------------[ cut here ]------------
WARNING: at mm/percpu.c:952 pcpu_alloc+0x610/0xfe0()
Modules linked in:

Call Trace:
 [<a0000001000162e0>] show_stack+0x40/0xa0
                                sp=A000000100c7fc30 bsp=A000000100c711f0
 [<a000000100016370>] dump_stack+0x30/0x60
                                sp=A000000100c7fe00 bsp=A000000100c711d8
 [<a00000010009b340>] warn_slowpath_common+0xc0/0x100
                                sp=A000000100c7fe00 bsp=A000000100c711a0
 [<a00000010009b3b0>] warn_slowpath_null+0x30/0x60
                                sp=A000000100c7fe00 bsp=A000000100c71178
 [<a00000010018d3f0>] pcpu_alloc+0x610/0xfe0
                                sp=A000000100c7fe00 bsp=A000000100c710e0
 [<a00000010018de50>] __alloc_percpu+0x30/0x60
                                sp=A000000100c7fe10 bsp=A000000100c710b8
 [<a00000010044a180>] __percpu_counter_init+0x60/0x120
                                sp=A000000100c7fe10 bsp=A000000100c71090
 [<a000000100ac1110>] mmap_init+0x30/0x60
                                sp=A000000100c7fe20 bsp=A000000100c71078
 [<a000000100ab6420>] proc_caches_init+0x1a0/0x1c0
                                sp=A000000100c7fe20 bsp=A000000100c71060
 [<a000000100aa1520>] start_kernel+0x7e0/0x8c0
                                sp=A000000100c7fe20 bsp=A000000100c70fe0
 [<a00000010085be60>] _start+0x760/0x780
                                sp=A000000100c7fe30 bsp=A000000100c70f40
---[ end trace 4eaa2a86a8e2da22 ]---
------------[ cut here ]------------
WARNING: at mm/vmalloc.c:106 vmap_page_range_noflush+0x3d0/0x460()
Modules linked in:

Call Trace:
 [<a0000001000162e0>] show_stack+0x40/0xa0
                                sp=A000000100c7fc40 bsp=A000000100c71300
 [<a000000100016370>] dump_stack+0x30/0x60
                                sp=A000000100c7fe10 bsp=A000000100c712e8
 [<a00000010009b340>] warn_slowpath_common+0xc0/0x100
                                sp=A000000100c7fe10 bsp=A000000100c712b0
 [<a00000010009b3b0>] warn_slowpath_null+0x30/0x60
                                sp=A000000100c7fe10 bsp=A000000100c71288
 [<a00000010015f470>] vmap_page_range_noflush+0x3d0/0x460
                                sp=A000000100c7fe10 bsp=A000000100c71210
 [<a00000010015f590>] vmap_page_range+0x30/0x60
                                sp=A000000100c7fe10 bsp=A000000100c711d0
 [<a00000010015f610>] map_vm_area+0x50/0xa0
                                sp=A000000100c7fe10 bsp=A000000100c711a0
 [<a00000010015f950>] __vmalloc_area_node+0x2f0/0x3a0
                                sp=A000000100c7fe10 bsp=A000000100c71158
 [<a00000010015fae0>] __vmalloc_node+0xe0/0x120
                                sp=A000000100c7fe20 bsp=A000000100c71118
 [<a00000010015fe60>] __vmalloc+0x40/0x60
                                sp=A000000100c7fe20 bsp=A000000100c710e8
 [<a000000100ac0350>] alloc_large_system_hash+0x2f0/0x4e0
                                sp=A000000100c7fe20 bsp=A000000100c71088
 [<a000000100ac58b0>] vfs_caches_init+0x150/0x280
                                sp=A000000100c7fe20 bsp=A000000100c71060
 [<a000000100aa1540>] start_kernel+0x800/0x8c0
                                sp=A000000100c7fe20 bsp=A000000100c70fe0
 [<a00000010085be60>] _start+0x760/0x780
                                sp=A000000100c7fe30 bsp=A000000100c70f40
---[ end trace 4eaa2a86a8e2da23 ]---
Dentry cache hash table entries: 1048576 (order: 7, 8388608 bytes)
Inode-cache hash table entries: 1048576 (order: 7, 8388608 bytes)
Mount-cache hash table entries: 4096
Unable to handle kernel paging request at virtual address 00d0000000000000
swapper[0]: Oops 8813272891392 [1]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 00001010084a2018 ifs : 800000000000038c ip  : [<a0000001001840e0>]   =
 Tain
ted: G        W  (2.6.31-rc5)
ip is at kmem_cache_alloc+0xc0/0x1a0
unat: 0000000000000000 pfs : 000000000000040b rsc : 0000000000000003
rnat: a000000101362dc8 bsps: a000000101363f6c pr  : 656960155aa6a659
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0930ffff00078000 ssd : 0930ffff00078000
b0  : a0000001001c6290 b6  : a0000001002fefe0 b7  : a000000100195b00
f6  : 0fff592492492483a4000 f7  : 0ffe7cd08000000000000
f8  : 1000f8000000000000000 f9  : 10008e000000000000000
f10 : 1000592492492483a4000 f11 : 1003e0000000000000049
r1  : a000000101547240 r2  : a000000101246438 r3  : a0000001011cacf0
r8  : 0000000000000000 r9  : 0000000000000000 r10 : a000000100c70ee4
r11 : 00000000003fffff r12 : a000000100c7fe20 r13 : a000000100c70000
r14 : 00d0000000000000 r15 : a00000010124644c r16 : a000000100db4f58
r17 : a000000101347b70 r18 : 656960155aa6a659 r19 : a000000100a004c0
r20 : 0000000000000000 r21 : e00000018012c098 r22 : 0000000000000006
r23 : 0000000000000008 r24 : 0000000000000370 r25 : e000000180130010
r26 : 0000000000000020 r27 : a000000100cb0200 r28 : a000000101347740
r29 : 0000000080000000 r30 : 00000000000000c1 r31 : a000000101246340

Call Trace:
 [<a0000001000162e0>] show_stack+0x40/0xa0
                                sp=A000000100c7f9f0 bsp=A000000100c712a0
 [<a000000100016bf0>] show_regs+0x850/0x8a0
                                sp=A000000100c7fbc0 bsp=A000000100c71248
 [<a00000010003a170>] die+0x1b0/0x2c0
                                sp=A000000100c7fbc0 bsp=A000000100c71200
 [<a000000100064570>] ia64_do_page_fault+0x8d0/0xa40
                                sp=A000000100c7fbc0 bsp=A000000100c711a8
 [<a00000010000c780>] ia64_native_leave_kernel+0x0/0x270
                                sp=A000000100c7fc50 bsp=A000000100c711a8
 [<a0000001001840e0>] kmem_cache_alloc+0xc0/0x1a0
                                sp=A000000100c7fe20 bsp=A000000100c71148
 [<a0000001001c6290>] alloc_vfsmnt+0x30/0x2e0
                                sp=A000000100c7fe20 bsp=A000000100c71108
 [<a000000100197450>] vfs_kern_mount+0x30/0x1a0
                                sp=A000000100c7fe20 bsp=A000000100c710c8
 [<a000000100197600>] kern_mount_data+0x40/0x60
                                sp=A000000100c7fe20 bsp=A000000100c710a0
 [<a000000100ac6970>] bdev_cache_init+0xb0/0x140
                                sp=A000000100c7fe20 bsp=A000000100c71088
 [<a000000100ac59a0>] vfs_caches_init+0x240/0x280
                                sp=A000000100c7fe20 bsp=A000000100c71060
 [<a000000100aa1540>] start_kernel+0x800/0x8c0
                                sp=A000000100c7fe20 bsp=A000000100c70fe0
 [<a00000010085be60>] _start+0x760/0x780
                                sp=A000000100c7fe30 bsp=A000000100c70f40
Disabling lock debugging due to kernel taint
Kernel panic - not syncing: Attempted to kill the idle task!

Thanks.

-Fenghua
