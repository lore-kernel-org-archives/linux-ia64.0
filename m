From: Jack Steiner <steiner@sgi.com>
Date: Thu, 02 Mar 2006 22:02:28 +0000
Subject: PATCH[3/4] - Increase max node count on SN platforms
Message-Id: <20060302220228.GA17147@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Node number are kept in the cpu_to_node_map which is
currently defined as u8. Change to u16 to accomodate
larger node numbers.



	Signed-off-by: Jack Steiner <steiner@sgi.com>


 arch/ia64/kernel/numa.c |    2 +-
 include/asm-ia64/numa.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)




Index: linux/arch/ia64/kernel/numa.c
=================================--- linux.orig/arch/ia64/kernel/numa.c	2006-03-02 13:18:50.720983429 -0600
+++ linux/arch/ia64/kernel/numa.c	2006-03-02 13:21:53.358501208 -0600
@@ -25,7 +25,7 @@
 #include <asm/processor.h>
 #include <asm/smp.h>
 
-u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+u16 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 EXPORT_SYMBOL(cpu_to_node_map);
 
 cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
Index: linux/include/asm-ia64/numa.h
=================================--- linux.orig/include/asm-ia64/numa.h	2006-03-02 13:18:50.721959896 -0600
+++ linux/include/asm-ia64/numa.h	2006-03-02 13:21:53.358501208 -0600
@@ -23,7 +23,7 @@
 
 #include <asm/mmzone.h>
 
-extern u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+extern u16 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 
 /* Stuff below this line could be architecture independent */
