From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 09 Sep 2004 01:02:54 +0000
Subject: Re: [PATCH] general config option cleanup
Message-Id: <20040909010254.GC24723@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="tqI+Z3u+9OQ7kwn0"
List-Id: <linux-ia64.vger.kernel.org>
References: <200409081447.38703.jbarnes@engr.sgi.com>
In-Reply-To: <200409081447.38703.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org


--tqI+Z3u+9OQ7kwn0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 08, 2004 at 02:47:38PM -0700, Jesse Barnes wrote:
> As threatened, here's a patch that unifies the ia64 memory init and memmap 
> codepaths by unconditionalizing the CONFIG_VIRTUAL_MEM_MAP code and making 
> CONFIG_DISCONTIGMEM required.  It also allows building with CONFIG_SMP=n 
> and/or CONFIG_NUMA=n. 

Two related things I noticed.  Firstly, shouldn't the ACPI_NUMA option
be linked to NUMA (i.e. if you select one, Kconfig selects the other)?

Secondly, trying to build with CONFIG_NUMA and CONFIG_ACPI_NUMA off
gave errors like

arch/ia64/mm/built-in.o(.init.text+0x3c0): In function `early_nr_cpus_node':
: undefined reference to `node_cpuid'
arch/ia64/mm/built-in.o(.init.text+0xf71): In function `call_pernode_memory':
: undefined reference to `num_node_memblks'

How about moving the definions in question either outside of #ifdef
CONFIG_ACPI_NUMA in apci.c or adding them to discontig.c (as below).

Thanks,

-i

Make it so that builds without NUMA/ACPI_NUMA (ontop of original patch)
===== arch/ia64/kernel/acpi.c 1.75 vs edited =====
--- 1.75/arch/ia64/kernel/acpi.c        2004-09-09 10:49:07 +10:00
+++ edited/arch/ia64/kernel/acpi.c      2004-09-09 10:53:06 +10:00
@@ -360,14 +360,6 @@
 int __initdata pxm_to_nid_map[MAX_PXM_DOMAINS];
 int __initdata nid_to_pxm_map[MAX_NUMNODES];

-/*
- * The following structures are usually initialized by ACPI or
- * similar mechanisms and describe the NUMA characteristics of the machine.
- */
-int num_node_memblks;
-struct node_memblk_s node_memblk[NR_NODE_MEMBLKS];
-struct node_cpuid_s node_cpuid[NR_CPUS];
-
 #ifdef CONFIG_NUMA

 static struct acpi_table_slit __initdata *slit_table;
===== arch/ia64/mm/discontig.c 1.19 vs edited =====
--- 1.19/arch/ia64/mm/discontig.c       2004-09-09 10:49:07 +10:00
+++ edited/arch/ia64/mm/discontig.c     2004-09-09 10:53:43 +10:00
@@ -40,6 +40,14 @@

 static struct early_node_data mem_data[NR_NODES] __initdata;

+/*
+ * The following structures are usually initialized by ACPI or
+ * similar mechanisms and describe the NUMA characteristics of the machine.
+ */
+int num_node_memblks;
+struct node_memblk_s node_memblk[NR_NODE_MEMBLKS];
+struct node_cpuid_s node_cpuid[NR_CPUS];
+
 #ifdef CONFIG_NUMA
 /**
  * reassign_cpu_only_nodes - called from find_memory to move CPU-only nodes to a memory node

--tqI+Z3u+9OQ7kwn0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBP6u+WDlSU/gp6ecRAkdqAKCYfWAa6G58F6rykN2TGx9CzCvEYACgwaJs
SAwl5PxgjGU9VHTmZF0bHsQ=
=vf3b
-----END PGP SIGNATURE-----

--tqI+Z3u+9OQ7kwn0--
