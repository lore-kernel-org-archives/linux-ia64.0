From: j-nomura@ce.jp.nec.com
Date: Thu, 13 Feb 2003 05:52:54 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.60)
Message-Id: <marc-linux-ia64-105590709805839@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I had to apply the patch below to build with CONFIG_NUMA.

> An updated ia64 patch is now at:
> 
>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/linux-2.5.60-ia64-030212.diff.gz
> 
> This is mostly a sync with Linus' tree.  The patch above contains some
> non-ia64 patches which are there because Linus pushed them into his
> bitkeeper tree after releasing 2.5.60 and before I picked it up.

--- linux.old/include/asm-ia64/topology.h
+++ linux/include/asm-ia64/topology.h
@@ -26,7 +26,7 @@
 /*
  * Returns a bitmask of CPUs on Node 'node'.
  */
-#define node_to_cpumask(node) (node_to_cpumask[node])
+#define node_to_cpumask(node) (node_to_cpu_mask[node])
 
 #else
 #define cpu_to_node(cpu) (0)


Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.

