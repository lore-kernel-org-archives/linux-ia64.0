From: David Rientjes <rientjes@google.com>
Date: Mon, 21 Sep 2009 09:13:59 +0000
Subject: Re: [PATCH] remove duplicate asm/mman.h files
Message-Id: <alpine.DEB.1.00.0909210208180.16086@chino.kir.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1251197514.git.ebmunson@us.ibm.com> <200909181848.42192.arnd@arndb.de> <alpine.DEB.1.00.0909181236190.27556@chino.kir.corp.google.com> <200909211031.25369.arnd@arndb.de>
In-Reply-To: <200909211031.25369.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>
Cc: ebmunson@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

On Mon, 21 Sep 2009, Arnd Bergmann wrote:

> > > -#define MCL_CURRENT	1		/* lock all current mappings */
> > > -#define MCL_FUTURE	2		/* lock all future mappings */
> > > +#define MAP_GROWSUP	0x0200		/* register stack-like segment */
> > >  
> > >  #ifdef __KERNEL__
> > >  #ifndef __ASSEMBLY__
> > 
> > ia64 doesn't use MAP_GROWSUP, so it's probably not necessary to carry it 
> > along with your cleanup.
> 
> ia64 is the only architecture defining it, nobody uses it in the kernel.
> If the ia64 maintainers want to remove it in a separate patch, that
> would probably be a good idea.
> 

I'll do it then.

> I tried not to change the ABI in any way in my patch, and there is
> a theoretical possibility that some user space program on ia64 currently
> depends on that definition.
> 

I don't buy that as justification, if some userspace program uses it based 
on the false belief that it actually does what it says, it's probably 
better to break their build than perpetuating the lie that it's different 
than ~MAP_GROWSDOWN.


ia64: remove definition for MAP_GROWSUP

MAP_GROWSUP is unused.

Signed-off-by: David Rientjes <rientjes@google.com>
---
diff --git a/arch/ia64/include/asm/mman.h b/arch/ia64/include/asm/mman.h
--- a/arch/ia64/include/asm/mman.h
+++ b/arch/ia64/include/asm/mman.h
@@ -11,7 +11,6 @@
 #include <asm-generic/mman-common.h>
 
 #define MAP_GROWSDOWN	0x00100		/* stack-like segment */
-#define MAP_GROWSUP	0x00200		/* register stack-like segment */
 #define MAP_DENYWRITE	0x00800		/* ETXTBSY */
 #define MAP_EXECUTABLE	0x01000		/* mark it as an executable */
 #define MAP_LOCKED	0x02000		/* pages are locked */
