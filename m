From: Vivek Goyal <vgoyal@redhat.com>
Date: Mon, 28 Jul 2008 21:15:14 +0000
Subject: [PATCH 5/5] sh: Define elfcorehdr_addr in arch dependent section
Message-Id: <20080728211514.GE9985@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080727234529.GM6175@verge.net.au> <20080728015117.GA12055@verge.net.au> <20080728024526.GB3334@verge.net.au> <20080728034007.GA30450@verge.net.au> <20080728211025.GA9985@redhat.com> <20080728211156.GB9985@redhat.com> <20080728211314.GC9985@redhat.com> <20080728211408.GD9985@redhat.com>
In-Reply-To: <20080728211408.GD9985@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Muli Ben-Yehuda <muli@il.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Chandru <chandru@in.ibm.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Terry Loftin <terry.loftin@hp.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org




o Move elfcorehdr_addr definition in arch dependent crash dump file. This is
  equivalent to defining elfcorehdr_addr under CONFIG_CRASH_DUMP instead of
  CONFIG_PROC_VMCORE. This is needed by is_kdump_kernel() which can be
  used irrespective of the fact whether CONFIG_PROC_VMCORE is enabled or
  not.

o I don't see sh setup code parsing the command line for elfcorehdr_addr. I 
  am wondering how does vmcore interface work on sh. Anyway, I am atleast
  defining elfcoredhr_addr so that compilation is not broken on sh.

Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
---

 arch/sh/kernel/crash_dump.c |    3 +++
 1 file changed, 3 insertions(+)

diff -puN arch/sh/kernel/crash_dump.c~fix-elfcorehdr_addr-sh arch/sh/kernel/crash_dump.c
--- linux-2.6.27-pre-rc1/arch/sh/kernel/crash_dump.c~fix-elfcorehdr_addr-sh	2008-07-28 12:17:12.000000000 -0400
+++ linux-2.6.27-pre-rc1-root/arch/sh/kernel/crash_dump.c	2008-07-28 12:17:12.000000000 -0400
@@ -10,6 +10,9 @@
 #include <linux/io.h>
 #include <asm/uaccess.h>
 
+/* Stores the physical address of elf header of crash image. */
+unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
+
 /**
  * copy_oldmem_page - copy one page from "oldmem"
  * @pfn: page frame number to be copied
_
