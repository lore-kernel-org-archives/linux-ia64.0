From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 07 Jan 2005 06:51:04 +0000
Subject: RE: [patch] per cpu MCA/INIT fixes.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02A67B68@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>An updated patch that applies on Jack's and builds with zx1 & tiger UP.
>The SGI UP is previously broke.  Jesse is working on that.

Build for tiger_defconfig looked pretty clean, but it doesn't boot :-(

No messages to console or serial console.  Peering into memory, I see
this in __log_buf:

<6>SAL Platform features: BusLock IRQ_Redirection.
<6>SAL: AP wakeup using external interrupt vector 0xf0.
<4>kernel BUG at mm/bootmem.c:158!.
<4>swapper[0]: bugcheck! 0 [1].
<4>Modules linked in:.
<4>.<4 >Pid: 0, CPU 0, comm:              swapper.
<4>psr : 00001010084a2010 ifs : 8000000000000690 ip  : [<a000000100766580>]    Not tainted.
<4>ip is at __alloc_bootmem_core+0x540/0x6e0.


Building with a generic config boots just fine.  So this is
possibly a discontig vs. contig problem?  Probably this allocation:

+               mca_data = __alloc_bootmem(PERCPU_MCA_SIZE * NR_CPUS,
+                                          PERCPU_MCA_SIZE, __pa(MAX_DMA_ADDRESS));

PERCPU_MCA_SIZE doesn't look likely to be a power of two, so using it
as the 'align' argument to __alloc_bootmem trips the BUG at mm/bootmem.c:158


-Tony
