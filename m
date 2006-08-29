From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 29 Aug 2006 21:13:29 +0000
Subject: RE: [RFC][PATCH 10/10] convert the "easy" architectures to generic
Message-Id: <1156886009.5408.183.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A728D28@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A728D28@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org

On Tue, 2006-08-29 at 14:06 -0700, Luck, Tony wrote:
> > Note that, as promised, this removes ARCH_GENERIC_PAGE_SIZE
> > introduced by the first patch in this series.  It is no longer
> > needed as _all_ architectures now use this infrastructure.
> 
> Either I goofed when applying these patches, or you missed one
> in mm/Kconfig.  The version I ended up with had the "Kernel Page Size"
> choice still "depends on ARCH_GENERIC_PAGE_SIZE" ... so make
> menuconfig didn't let me choose the page size.

Yeah, during all of my repatching, I managed to forget to rip that out.
Thanks for finding that.  Just killing that depends line, or applying
this should fix it.

-- Dave

 threadalloc-dave/mm/Kconfig |    1 -
 1 files changed, 1 deletion(-)

diff -puN mm/Kconfig~fix-mm-Kconfig mm/Kconfig
--- threadalloc/mm/Kconfig~fix-mm-Kconfig	2006-08-29 14:11:25.000000000 -0700
+++ threadalloc-dave/mm/Kconfig	2006-08-29 14:11:26.000000000 -0700
@@ -4,7 +4,6 @@ config ARCH_HAVE_GET_ORDER
 
 choice
 	prompt "Kernel Page Size"
-	depends on ARCH_GENERIC_PAGE_SIZE
 	default PAGE_SIZE_4KB if MIPS || PARISC
 	default PAGE_SIZE_8KB if SPARC64
 	default PAGE_SIZE_16KB if IA64
_

