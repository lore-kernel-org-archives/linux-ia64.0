From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Jul 2003 06:04:34 +0000
Subject: Re: Can't build current snapshot
Message-Id: <marc-linux-ia64-105833548505951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832832401236@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832832401236@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 Jul 2003 15:35:20 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> I've just cleared out ccache and done a make mrproper; make
  Peter> config; make.  The same relocation errors appear.

OK.

  Peter> There's something funny going on here, because the offending symbol is
  Peter> defined and used in setup.c (and entry.S), not efi.c

  Peter> It's put in the data section.
  Peter> $ nm arch/ia64/kernel/setup.o|grep ia64_phys_
  Peter> 0000000000000028 G per_cpu__ia64_phys_stacked_size_p8

  Peter> I'm a little suprised that it isn't in the BSS.

  Peter> There is no per-cpu area as such.
  Peter> CONFIG_SMP is not defined, so DEFINE_PER_CPU
  Peter> doesn't put the per_cpu variables into a separate segment

  Peter> From asm-ia64/percpu.h:

  Peter> #define DEFINE_PER_CPU(type, name) __typeof__(type) per_cpu__##name

Oh, it all makes sense now.  Yes, on UP we failed to put per-CPU stuff
in a special section.  We have to do that now, so that the variables
remain "addl"-addressable.

The patch below should fix the problem.

Thanks for tracking this down.

	--david

=== include/asm-ia64/percpu.h 1.9 vs edited ==--- 1.9/include/asm-ia64/percpu.h	Tue Jul 15 14:39:31 2003
+++ edited/include/asm-ia64/percpu.h	Tue Jul 15 22:49:34 2003
@@ -18,6 +18,10 @@
 
 #define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
 
+/* Separate out the type, so (int[3], foo) works. */
+#define DEFINE_PER_CPU(type, name) \
+    __attribute__((__section__(".data.percpu"))) __typeof__(type) per_cpu__##name
+
 /*
  * Pretty much a literal copy of asm-generic/percpu.h, except that percpu_modcopy() is an
  * external routine, to avoid include-hell.
@@ -29,10 +33,6 @@
 /* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
 DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
 
-/* Separate out the type, so (int[3], foo) works. */
-#define DEFINE_PER_CPU(type, name) \
-    __attribute__((__section__(".data.percpu"))) __typeof__(type) per_cpu__##name
-
 #define per_cpu(var, cpu)  (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset[cpu]))
 #define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
 
@@ -40,7 +40,6 @@
 
 #else /* ! SMP */
 
-#define DEFINE_PER_CPU(type, name)		__typeof__(type) per_cpu__##name
 #define per_cpu(var, cpu)			((void)cpu, per_cpu__##var)
 #define __get_cpu_var(var)			per_cpu__##var
 
