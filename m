From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 06:02:30 +0000
Subject: Re: [PATCH 03/28] ia64/xen: increase IA64_MAX_RSVD_REGIONS.
Message-Id: <20080222060230.GB16685%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036570474112-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036570474112-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 21, 2008 at 11:33:16PM -0600, Robin Holt wrote:
> On Fri, Feb 22, 2008 at 02:10:19PM +0900, Isaku Yamahata wrote:
> > Xenlinux/ia64 needs to reserve one more region passed from xen hypervisor
> > as start info.
> > 
> > Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> > ---
> >  include/asm-ia64/meminit.h |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
> > index f93308f..7c12c08 100644
> > --- a/include/asm-ia64/meminit.h
> > +++ b/include/asm-ia64/meminit.h
> > @@ -18,10 +18,17 @@
> >   * 	- crash dumping code reserved region
> >   * 	- Kernel memory map built from EFI memory map
> >   * 	- ELF core header
> > + * ifdef CONFIG_XEN
> > + *	- xen start info
> > + * endif
> >   *
> >   * More could be added if necessary
> >   */
> > +#ifdef CONFIG_XEN
> >  #define IA64_MAX_RSVD_REGIONS 8
> > +#else
> > +#define IA64_MAX_RSVD_REGIONS 9
> > +#endif
> 
> This one seems upside down to me.  You are saying there is an additional
> region when CONFIG_XEN, but you are defining it larger for !CONFIG_XEN.
> I concede the point that I know nothing about Xen, so please straighten
> me out here.

Thank you for review. You're absolutely correct.

---
ia64/xen: increase IA64_MAX_RSVD_REGIONS.

Xenlinux/ia64 needs to reserve one more region passed from xen hypervisor
as start info.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/meminit.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
index f93308f..3de9c74 100644
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
@@ -18,10 +18,17 @@
  * 	- crash dumping code reserved region
  * 	- Kernel memory map built from EFI memory map
  * 	- ELF core header
+ * ifdef CONFIG_XEN
+ *	- xen start info
+ * endif
  *
  * More could be added if necessary
  */
+#ifndef CONFIG_XEN
 #define IA64_MAX_RSVD_REGIONS 8
+#else
+#define IA64_MAX_RSVD_REGIONS 9
+#endif
 
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
-- 
1.5.3



-- 
yamahata
