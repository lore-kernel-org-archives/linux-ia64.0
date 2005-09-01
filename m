From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 01 Sep 2005 04:59:49 +0000
Subject: RE: ip_contrack refuses to load if built UP as a module on IA64
Message-Id: <17174.35525.283392.703723@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0443A5FA@scsmsx401.amr.corp.intel.com>     <ed5aea430508301229386fc596@mail.gmail.com>     <17172.54563.329758.846131@wombat.chubb.wattle.id.au>
In-Reply-To: <ed5aea43050830150112ee6103@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, tony.luck@intel.com, dmosberger@gmail.com
Cc: linux-kernel@vger.kernel.org



This patch makes UP and SMP do the same thing as far as module per-cpu
data go.

Unfortunately it affects core code.

To repeat the problem:
  IA64 keeps per-cpu data in a small data area that is referenced by a
  22-bit offset, for both UP and SMP cases.  If a module defines
  per-cpu data, it too will end up in the small-data area.  But the
  module loader at present special-cases the UP treatment of per-cpu
  data, assumes that it is in the GP-relative data area, and does
  nothing (for SMP it allocates space, and copies initialised data
  items into it) 

  The effect is that modules defining per-cpu data fail to load if
  they're built UP, because of an impossible relocation.

  The appended patch makes the treatment of per-cpu data uniform
  between UP and SMP cases.  For most architectures, the per-cpu data
  section will be empty for UP, and so the per-cpu setup code will not
  be invoked.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -951,4 +951,10 @@ percpu_modcopy (void *pcpudst, const voi
 		if (cpu_possible(i))
 			memcpy(pcpudst + __per_cpu_offset[i], src, size);
 }
+#else
+void
+percpu_modcopy (void *pcpudst, const void *src, unsigned long size)
+{
+	memcpy(pcpudst, src, size);
+}
 #endif /* CONFIG_SMP */
diff --git a/kernel/module.c b/kernel/module.c
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -209,7 +209,6 @@ static struct module *find_module(const 
 	return NULL;
 }
 
-#ifdef CONFIG_SMP
 /* Number of blocks used and allocated. */
 static unsigned int pcpu_num_used, pcpu_num_allocated;
 /* Size of each block.  -ve means used. */
@@ -352,29 +351,7 @@ static int percpu_modinit(void)
 	return 0;
 }	
 __initcall(percpu_modinit);
-#else /* ... !CONFIG_SMP */
-static inline void *percpu_modalloc(unsigned long size, unsigned long align,
-				    const char *name)
-{
-	return NULL;
-}
-static inline void percpu_modfree(void *pcpuptr)
-{
-	BUG();
-}
-static inline unsigned int find_pcpusec(Elf_Ehdr *hdr,
-					Elf_Shdr *sechdrs,
-					const char *secstrings)
-{
-	return 0;
-}
-static inline void percpu_modcopy(void *pcpudst, const void *src,
-				  unsigned long size)
-{
-	/* pcpusec should be 0, and size of that section should be 0. */
-	BUG_ON(size != 0);
-}
-#endif /* CONFIG_SMP */
+
 
 #ifdef CONFIG_MODULE_UNLOAD
 #define MODINFO_ATTR(field)	\
