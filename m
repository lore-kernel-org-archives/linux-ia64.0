From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 20 Sep 2005 07:34:41 +0000
Subject: Re: [patch] MCA recovery verify pfn_valid
Message-Id: <432FBB91.9020403@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040800060505050303050400"
List-Id: <linux-ia64.vger.kernel.org>
References: <200509162154.j8GLsrWN2681135@efs.americas.sgi.com>
In-Reply-To: <200509162154.j8GLsrWN2681135@efs.americas.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040800060505050303050400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

How about this?

Thanks,
H.Seto

Verify the pfn is valid before calling pfn_to_page(),
and cut isolation message if nothing was done.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

Russ Anderson wrote:
> Jack Steiner wrote:
>>
>>Perhaps another status should be returned.
> 
> In this case, is any message really needed?  As you say, success is
> is misleading because nothing was done.  Failure is not accurate
> because it didn't fail.  So perhaps a third status that does not
> print any page isolation message is the best solution.

--------------040800060505050303050400
Content-Type: text/plain;
 name="mca_drv_pfnverify.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mca_drv_pfnverify.patch"

 arch/ia64/kernel/mca_drv.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

Index: build/arch/ia64/kernel/mca_drv.c
===================================================================
--- build.orig/arch/ia64/kernel/mca_drv.c
+++ build/arch/ia64/kernel/mca_drv.c
@@ -56,8 +56,9 @@ static struct page *page_isolate[MAX_PAG
 static int num_page_isolate = 0;
 
 typedef enum {
-	ISOLATE_NG = 0,
-	ISOLATE_OK = 1
+	ISOLATE_NG,
+	ISOLATE_OK,
+	ISOLATE_NONE
 } isolate_status_t;
 
 /*
@@ -74,7 +75,7 @@ static struct {
  * @paddr:	poisoned memory location
  *
  * Return value:
- *	ISOLATE_OK / ISOLATE_NG
+ *	one of isolate_status_t, ISOLATE_OK/NG/NONE.
  */
 
 static isolate_status_t
@@ -85,7 +86,10 @@ mca_page_isolate(unsigned long paddr)
 
 	/* whether physical address is valid or not */
 	if (!ia64_phys_addr_valid(paddr))
-		return ISOLATE_NG;
+		return ISOLATE_NONE;
+
+	if (!pfn_valid(paddr))
+		return ISOLATE_NONE;
 
 	/* convert physical address to physical page number */
 	p = pfn_to_page(paddr>>PAGE_SHIFT);
@@ -122,10 +126,15 @@ mca_handler_bh(unsigned long paddr)
 		current->pid, current->comm);
 
 	spin_lock(&mca_bh_lock);
-	if (mca_page_isolate(paddr) == ISOLATE_OK) {
+	switch (mca_page_isolate(paddr)) {
+	case ISOLATE_OK:
 		printk(KERN_DEBUG "Page isolation: ( %lx ) success.\n", paddr);
-	} else {
+		break;
+	case ISOLATE_NG:
 		printk(KERN_DEBUG "Page isolation: ( %lx ) failure.\n", paddr);
+		break;
+	default:
+		break;
 	}
 	spin_unlock(&mca_bh_lock);
 

--------------040800060505050303050400--

