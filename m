From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 29 Oct 2008 05:07:41 +0000
Subject: Re: linux-next: Tree for October 28
Message-Id: <20081028220741.f5d331ba.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081028183055.fbcf5420.sfr@canb.auug.org.au>
In-Reply-To: <20081028183055.fbcf5420.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, linux-wireless@vger.kernel.org, Mark Fasheh <mfasheh@suse.com>, Joel Becker <Joel.Becker@oracle.com>

On Tue, 28 Oct 2008 18:30:55 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> I have created today's linux-next tree at
> git://git.kernel.org/pub/scm/linux/kernel/git/sfr/linux-next.git
> (patches at
> http://www.kernel.org/pub/linux/kernel/people/sfr/linux-next/).

ia64 allmodconfig:

arch/ia64/kernel/iosapic.c: In function `get_target_cpu':
arch/ia64/kernel/iosapic.c:723: error: `nr_cpus_ids' undeclared (first use in this function)
arch/ia64/kernel/iosapic.c:723: error: (Each undeclared identifier is reported only once
arch/ia64/kernel/iosapic.c:723: error: for each function it appears in.)

Fixed by:

From: Andrew Morton <akpm@linux-foundation.org>

- someone can't type (or test)

- nr_cpu_ids is declared in cpumask.h.  Include it.

--- a/arch/ia64/kernel/iosapic.c~ia64-fix-arch-ia64-kernel-iosapicc-build
+++ a/arch/ia64/kernel/iosapic.c
@@ -85,6 +85,7 @@
 #include <linux/irq.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
+#include <linux/cpumask.h>
 #include <linux/pci.h>
 #include <linux/smp.h>
 #include <linux/string.h>
@@ -720,7 +721,7 @@ get_target_cpu (unsigned int gsi, int ir
 		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
 			numa_cpu = next_cpu(numa_cpu, cpu_mask);
 
-		if (numa_cpu < nr_cpus_ids)
+		if (numa_cpu < nr_cpu_ids)
 			return cpu_physical_id(numa_cpu);
 	}
 skip_numa_setup:
_



also rather a lot of these:


In file included from drivers/misc/sgi-gru/gruhandles.h:25,
                 from drivers/misc/sgi-gru/grutables.h:151,
                 from drivers/misc/sgi-gru/grufile.c:41:
drivers/misc/sgi-gru/gru_instructions.h: In function `gru_flush_cache':
drivers/misc/sgi-gru/gru_instructions.h:292: warning: passing arg 1 of pointer to function makes integer from pointer without a cast
In file included from drivers/misc/sgi-gru/gruhandles.h:25,
                 from drivers/misc/sgi-gru/grutables.h:151,
                 from drivers/misc/sgi-gru/grumain.c:22:
drivers/misc/sgi-gru/gru_instructions.h: In function `gru_flush_cache':
drivers/misc/sgi-gru/gru_instructions.h:292: warning: passing arg 1 of pointer to function makes integer from pointer without a cast



and this:


kernel/trace/trace.c: In function `tracing_generic_entry_update':
kernel/trace/trace.c:681: error: implicit declaration of function `irqs_disabled_flags'
kernel/trace/trace.c: In function `kretprobed':
kernel/trace/trace.c:1112: error: `kretprobe_trampoline' undeclared (first use in this function)
kernel/trace/trace.c:1112: error: (Each undeclared identifier is reported only once
kernel/trace/trace.c:1112: error: for each function it appears in.)


and wireless needs some Kconfig help.  Please don't just break other
architecture's build like this.

drivers/staging/wlan-ng/wlan_compat.h:136:3: #error "No CPU identified!"
drivers/staging/wlan-ng/wlan_compat.h:695:6: warning: "WLAN_CPU_FAMILY" is not defined
drivers/staging/wlan-ng/wlan_compat.h:699:6: warning: "WLAN_CPU_FAMILY" is not defined



plus of course enough compile warnings to start a small war.   ocfs2 is prominent.

fs/ocfs2/xattr.c: In function `ocfs2_xattr_index_block_find':
fs/ocfs2/xattr.c:2338: warning: long long unsigned int format, u64 arg (arg 7)
fs/ocfs2/xattr.c:2338: warning: long long unsigned int format, u64 arg (arg 7)
fs/ocfs2/xattr.c:2338: warning: long long unsigned int format, u64 arg (arg 7)
fs/ocfs2/xattr.c: In function `ocfs2_iterate_xattr_buckets':
fs/ocfs2/xattr.c:2362: warning: long long unsigned int format, u64 arg (arg 7)
fs/ocfs2/xattr.c:2362: warning: long long unsigned int format, u64 arg (arg 7)
fs/ocfs2/xattr.c:2362: warning: long long unsigned int format, u64 arg (arg 7)
fs/ocfs2/xattr.c:2381: warning: long long unsigned int format, u64 arg (arg 6)
fs/ocfs2/xattr.c:2381: warning: long long unsigned int format, u64 arg (arg 6)
fs/ocfs2/xattr.c:2381: warning: long long unsigned int format, u64 arg (arg 6)
fs/ocfs2/xattr.c: In function `ocfs2_xattr_create_index_block':
fs/ocfs2/xattr.c:2717: warning: long long unsigned int format, u64 arg (arg 6)
fs/ocfs2/xattr.c:2717: warning: long long unsigned int format, u64 arg (arg 6)

