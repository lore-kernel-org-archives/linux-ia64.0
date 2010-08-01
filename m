From: Luming Yu <luming.yu@gmail.com>
Date: Sun, 01 Aug 2010 10:10:29 +0000
Subject: Re: [RFC PATCH --take 2] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT
Message-Id: <AANLkTikLLuyz7x4XVcVKb=WGXEe8vxLdQOH=La1-+dyA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
In-Reply-To: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

> Next I turned on some lockdep options under the "Kernel Hacking"
> menu. But probably not the same set that you used for you test.
> My kernel crashed during boot with:
>
> PID hash table entries: 4096 (order: -1, 32768 bytes)
> Placing 64MB software IO TLB between e000000007580000 - e00000000b580000
> software IO TLB at phys 0x7580000 - 0xb580000
> ------------[ cut here ]------------
> WARNING: at kernel/lockdep.c:2310 trace_hardirqs_on_caller+0x220/0x380()
> Modules linked in:
> kernel unaligned access to 0xffffffffffffffff, ip=0xa0000001001aaf41
> swapper[0]: error during unaligned kernel access
>  -1 [1]
> Modules linked in:
>
> Pid: 0, CPU 0, comm:              swapper
> psr : 0000121008022018 ifs : 800000000000048e ip  :
> [<a0000001001aaf41>]    Not tainted
> (2.6.35-rc3-generic-smp-1-ge892a33)
> ip is at kmem_cache_alloc+0xc1/0x220
>

The noticeable difference is the change from SLAB to SLUB in my good
configure and
generic_defconfig, and the lockdep code seems to be accessing an invalid address
somehow from SLUB, while similar lockde invocation from SLAB seems to
be working.

I'm running a kernel (generic_defconfig)  with the following
workaround to see I can run how long until I could see another lockdep
warning

diff --git a/kernel/lockdep.c b/kernel/lockdep.c
index 5428679..1407c56 100644
--- a/kernel/lockdep.c
+++ b/kernel/lockdep.c
@@ -2306,9 +2306,13 @@ void trace_hardirqs_on_caller(unsigned long ip)

        if (unlikely(!debug_locks || current->lockdep_recursion))
                return;
-
+#if 0
        if (DEBUG_LOCKS_WARN_ON(unlikely(!early_boot_irqs_enabled)))
                return;
+#else
+       if ((unlikely(!early_boot_irqs_enabled)))
+               return;
+#endif

        if (unlikely(curr->hardirqs_enabled)) {
                /*
