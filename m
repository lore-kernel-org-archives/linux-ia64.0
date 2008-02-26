From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Feb 2008 01:57:42 +0000
Subject: Re: [PATCH 03/28] ia64/xen: increase IA64_MAX_RSVD_REGIONS.
Message-Id: <20080226015742.GF29257%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036570474112-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036570474112-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 25, 2008 at 10:18:52AM -0700, Bjorn Helgaas wrote:
> On Thursday 21 February 2008 10:10:19 pm Isaku Yamahata wrote:
> > Xenlinux/ia64 needs to reserve one more region passed from xen hypervisor
> > as start info.
> 
> I don't think it's really worth adding an ifdef here to save
> one struct rsvd_region (two longs).  Why not just increase
> IA64_MAX_RSVD_REGIONS to 9 for everybody, and get rid of the
> ifdef?

Thank you for comment. It works for me.
ia64/xen: increase IA64_MAX_RSVD_REGIONS.

Xenlinux/ia64 needs to reserve one more region passed from xen hypervisor
as start info.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/meminit.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
index f93308f..8de94e2 100644
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
@@ -18,10 +18,11 @@
  * 	- crash dumping code reserved region
  * 	- Kernel memory map built from EFI memory map
  * 	- ELF core header
+ *	- xen start info if CONFIG_XEN
  *
  * More could be added if necessary
  */
-#define IA64_MAX_RSVD_REGIONS 8
+#define IA64_MAX_RSVD_REGIONS 9
 
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
-- 
1.5.3



-- 
yamahata
