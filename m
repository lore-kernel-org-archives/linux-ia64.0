From: Jean-Marc Saffroy <jean-marc.saffroy@ext.bull.net>
Date: Wed, 21 Apr 2004 21:56:01 +0000
Subject: [PATCH] module relocation code
Message-Id: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

(First, note that although the following is specific to Linux/ia64, I
suspect the problem described here may apply to other architectures as
well.)

While loading/unloading many large kernel modules on 2.6.3/ia64, we have
found a bug in the code that computes relocations for modules.

Memory for a module is allocated in platform-independant code with 2 calls
to vmalloc: one for the .init sections, and one for the rest of the
module. But the current ia64 code handling PCREL21B relocations forgets
this and assumes that as long as the module calls its own code, not plt
entry is required.

If the .init code calls the core module code, and if there is more than
32MB(?) between these locations, then the computed offset for branching
does not fit in 21 bits, and apply_imm21b refuses to patch the code
(fortunately :-). The kernel does not load the module and complains with a
message like:
  value 1236602 out of IMM21b range

The following patch handles this by allocating a plt entry for every
PCREL21B relocation in the init section that calls core module code. I've
added a check for .init code that could be called from the core module,
since I don't know if this is done anywhere else. An alternate solution
could be to use a plt only when offsets are larger than 21 bits
(untested).

I suspect that other types of relocation that use "short" GP- or
IP-relative offsets have the same problem, but first I'd like to have
confirmation from people who are more knowledgeable on this.

Here is a fix for R_IA64_PCREL21B (should apply to 2.6.5 as is):

Index: linux-2.6.3/arch/ia64/kernel/module.c
=================================--- linux-2.6.3.orig/arch/ia64/kernel/module.c	Fri Apr 16 14:37:06 2004
+++ linux-2.6.3/arch/ia64/kernel/module.c	Wed Apr 21 17:06:07 2004
@@ -657,7 +657,19 @@
 		switch (r_type) {
 		      case R_IA64_PCREL21B:
 			/* special because it can cross into other module/kernel-core.  */
-			if (!is_internal(mod, val))
+			if (in_init(mod, val)) {
+				if(in_core(mod, (uint64_t)location)) {
+					/* paranoia? */
+					printk(KERN_ERR "%s: .init symbol 0x%lx used in module core at %p\n",
+						mod->name, val, location);
+					return -ENOEXEC;
+				}
+			} else if(in_core(mod, val)) {
+				if(in_init(mod, (uint64_t)location)) {
+					val = get_fdesc(mod, val, &ok);
+					val = get_plt(mod, location, val, &ok);
+				}
+			} else
 				val = get_plt(mod, location, val, &ok);
 			/* FALL THROUGH */
 		      default:


-- 
Jean-Marc Saffroy - jean-marc.saffroy@ext.bull.net

