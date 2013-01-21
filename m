From: Ben Widawsky <ben@bwidawsk.net>
Date: Mon, 21 Jan 2013 22:06:53 +0000
Subject: Re: [PATCH v4 00/13] Add gdb python scripts as kernel debugging helpers
Message-Id: <20130121140653.731a0951@bwidawsk.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1358787929.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1358787929.git.jan.kiszka@siemens.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Kiszka <jan.kiszka@siemens.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, Tom Tromey <tromey@redhat.com>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Kay Sievers <kay@vrfy.org>, linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, Michal Marek <mmarek@suse.cz>, sparclinux@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Mon, 21 Jan 2013 18:06:07 +0100
Jan Kiszka <jan.kiszka@siemens.com> wrote:

> Version 4 of this series is a rebase over latest 3.8-rc4+. Moreover, I
> updated the mechanism that implements automatic symbol loading for new
> modules. It was affected by the refactorings around finit_module.
> 
> While waiting for feedback who could imagine picking this up for merge,
> I wrote a tiny tutorial, see below.
> 
> 
> Here is the original series intro again:
> 
> This adds the infrastructure and first tools that make kernel debugging
> through gdb more comfortable. Since 7.0, gdb supports python scripting.
> And this opens the doors to automate steps like the tedious loading of
> module symbols at the right address, resolving per-cpu variables or even
> retrieving the current kernel log without resuming an stopped target.
> 
> Many of the helpers naturally depend on the layout of structures or
> internal mechanics of the kernel. So the best place to maintain such
> things, keeping them consistent with the corresponding kernel is, well,
> the kernel itself.
> 
> While these scripts have been originally developed for debugging via
> QEMU/KVM, I've now also added the required bits for KGDB. Works fine,
> but as QEMU/KVM tends to outperform KGDB it remains the recommendation
> - when available.
> 
> There are two architecture dependencies so far, one regarding per-cpu,
> the other regarding thread_info calculation. None of them I was able to
> test on a target, so I'm counting on review/testing by the corresponding
> communities.
> 
> This series should be considered the foundation of much more kernel
> state exploration helpers, e.g. around tasks, timers, locks, sockets -
> I guess people will have even more ideas.
> 
> 
> And this is a tutorial for the gdb extension using QEMU/KVM as target
> platform:
> 
>  o Set up a virtual Linux machine for KVM (see www.linux-kvm.org and
>    www.qemu.org for more details)
> 
>  o Build the kernel with this series applied, enabling CONFIG_DEBUG_INFO
>    (but leave CONFIG_DEBUG_INFO_REDUCED off)
> 
>  o Install that kernel on the guest
> 
>  o Enable the gdb stub of QEMU/KVM, either
>     - at VM startup time by appending "-s" to the QEMU command line
>    or
>     - during runtime by issuing "gdbserver" from the QEMU monitor
>       console
> 
>  o cd /path/to/linux-build
> 
>  o Start gdb: gdb vmlinux
> 
>  o Attach to the booted guest:
>     (gdb) target remote :1234
> 
>  o Load module (and main kernel) symbols:
>     (gdb) lx-symbols
>     loading vmlinux
>     scanning for modules in /home/user/linux/build
>     loading @0xffffffffa0020000: /home/user/linux/build/net/netfilter/xt_tcpudp.ko
>     loading @0xffffffffa0016000: /home/user/linux/build/net/netfilter/xt_pkttype.ko
>     loading @0xffffffffa0002000: /home/user/linux/build/net/netfilter/xt_limit.ko
>     loading @0xffffffffa00ca000: /home/user/linux/build/net/packet/af_packet.ko
>     loading @0xffffffffa003c000: /home/user/linux/build/fs/fuse/fuse.ko
>     ...
>     loading @0xffffffffa0000000: /home/user/linux/build/drivers/ata/ata_generic.ko
> 
>  o Set a breakpoint on some not yet loaded module function, e.g.:
>     (gdb) b btrfs_init_sysfs
>     Function "btrfs_init_sysfs" not defined.
>     Make breakpoint pending on future shared library load? (y or [n]) y
>     Breakpoint 1 (btrfs_init_sysfs) pending.
> 
>  o Continue the target
> 
>  o Load the module on the target and watch what happens:
>     loading @0xffffffffa0034000: /home/user/linux/build/lib/libcrc32c.ko
>     loading @0xffffffffa0050000: /home/user/linux/build/lib/lzo/lzo_compress.ko
>     loading @0xffffffffa006e000: /home/user/linux/build/lib/zlib_deflate/zlib_deflate.ko
>     loading @0xffffffffa01b1000: /home/user/linux/build/fs/btrfs/btrfs.ko
> 
>     Breakpoint 1, btrfs_init_sysfs () at /home/user/linux/fs/btrfs/sysfs.c:36
>     36              btrfs_kset = kset_create_and_add("btrfs", NULL, fs_kobj);
> 
>  o Let's examine the current task a bit:
>     (gdb) p ().pid
>      = 4998
>     (gdb) p ().comm
>      = "modprobe\000\000\000\000\000\000\000"
> 
>  o Dump the log buffer of target kernel:
>     (gdb) lx-dmesg
>     [     0.000000] Initializing cgroup subsys cpuset
>     [     0.000000] Initializing cgroup subsys cpu
>     [     0.000000] Linux version 3.8.0-rc4-dbg+ (...
>     [     0.000000] Command line: root=/dev/sda2 resume=/dev/sda1 vga=0x314
>     [     0.000000] e820: BIOS-provided physical RAM map:
>     [     0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
>     [     0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
>     ....
> 
>  o Make use of the per-cpu helper for the current or a specified CPU:
>     (gdb) p ("runqueues").nr_running
>      = 1
>     (gdb) p ("runqueues", 2).nr_running
>      = 0
> 
>  o And now we are digging deep into hrtimers using the container_of
>    helper:
>     (gdb) set  = ("hrtimer_bases").clock_base[0].active.next
>     (gdb) p *(, "struct hrtimer", "node")
>      = {
>       node = {
>         node = {
>           __rb_parent_color = 18446612133355256072,
>           rb_right = 0x0 <irq_stack_union>,
>           rb_left = 0x0 <irq_stack_union>
>         },
>         expires = {
>           tv64 = 1835268000000
>         }
>       },
>       _softexpires = {
>         tv64 = 1835268000000
>       },
>       function = 0xffffffff81078232 <tick_sched_timer>,
>       base = 0xffff88003fd0d6f0,
>       state = 1,
>       start_pid = 0,
>       start_site = 0xffffffff81055c1f <hrtimer_start_range_ns+20>,
>       start_comm = "swapper/2\000\000\000\000\000\000"
>     }
> 
> Hope this provided some ideas and inspirations on how the commands and
> helper functions can support kernel development.
> 
> Enjoy,
> Jan
> 
> PS: Also available via git://git.kiszka.org/linux.git queues/gdb-scripts
> 
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Fenghua Yu <fenghua.yu@intel.com>
> CC: Kay Sievers <kay@vrfy.org>
> CC: linux-ia64@vger.kernel.org
> CC: linux-kbuild@vger.kernel.org
> CC: Michal Marek <mmarek@suse.cz>
> CC: sparclinux@vger.kernel.org
> CC: Tony Luck <tony.luck@intel.com>

My less than useful from v3 still applies:
Acked-by: Ben Widawsky <ben@bwidawsk.net>

I'm not really an appropriate person to review, but I've mde heavy use
of lx-symbols and lx-dmesg and am very happy.

-- 
Ben Widawsky, Intel Open Source Technology Center
