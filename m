From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 17 Dec 2002 02:11:46 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805587@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In message <20021216173238.A13794@twiddle.net> you write:
> On Tue, Dec 17, 2002 at 12:14:43PM +1100, Rusty Russell wrote:
> > Well, yes, something is wrong with the relocations.  The asm there
> > looks OK (assuming I'm reading it correctly, which is not guaranteed),
> > and I thought I put everything in the right place, but obviously not
> > 8(  After two days on and off of trying to get ia64 to work, I passed
> > the buck. 8(
> 
> Found it.  First, some general fixes, attached.  
> 
> The remaining problem is that you're confusing the code address of a
> symbol as seen via the module's local symbol table, and the descriptor
> address as seen via EXPORT_SYMBOL from another module.
> 
> This makes
> 
> +			fixup_plt(location, value);
> 
> incorrect for local symbols.  Which can be seen when the call to
> function() crashes.
> 
> You're going to have to distinguish between symbols retrieved from 
> the local symbol table and symbols retrieved from EXPORT_SYMBOL, and
> treat them differently in the IPLT case.

if (owner = me) should do this.

On top of your patch and my previous, this works!

Thanks!
Rusty.

diff -ur --exclude '*~' module-test-framework-ia64/arch-ia64/module.c module-test-framework/arch-ia64/module.c
--- module-test-framework-ia64/arch-ia64/module.c	2002-12-17 12:58:43.000000000 +1100
+++ module-test-framework/arch-ia64/module.c	2002-12-17 13:08:58.000000000 +1100
@@ -72,7 +73,7 @@
 		   unsigned long *extra)
 {
 	void *ptr;
-	Elf32_Phdr *phdr = (void *)hdr + hdr->e_phoff;
+	Elf64_Phdr *phdr = (void *)hdr + hdr->e_phoff;
 
 	/* Ensure we stay aligned to requirements of first segment:
            (assume it's sane, so vmalloc just works). */
@@ -117,19 +118,7 @@
 	return NULL;
 }
 
-static u64 calculate_got(struct module *owner)
-{
-	u64 got;
-	if (!owner) {
-		/* Kernel's GOT value = our current gp. */
-		asm("mov %0 = gp" : "=r" (got));
-		DEBUGP("GOT = %lu\n", got);
-	} else
-		got = owner->arch.got;
-	return got;
-}
-
-static inline void fixup_plt(void *xplt, u64 value)
+static inline void copy_plt(void *xplt, u64 value)
 {
 	struct ia64_fdesc *plt = xplt;
 	struct ia64_fdesc *fdesc = (void *)value;
@@ -137,6 +126,13 @@
 	*plt = *fdesc;
 }
 
+static inline void create_plt(void *xplt, u64 value, u64 got)
+{
+	struct ia64_fdesc *plt = xplt;
+	plt->entry = value;
+	plt->gp = got;
+}
+
 int apply_relocate(Elf_Rel *rel,
 		   unsigned int num_rel,
 		   Elf_Dyn *dyn,
@@ -204,7 +200,10 @@
 		case R_IA64_IPLTLSB:
 			printk("PLT location %p -> %p\n", location,
 			       (void *)value);
-			fixup_plt(location, value);
+			if (owner = me) /* Local symbol */
+				create_plt(location, value, me->arch.got);
+			else
+				copy_plt(location, value);
 			break;
 
 		default:
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

