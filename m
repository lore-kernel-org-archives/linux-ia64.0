From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 14 Mar 2003 22:41:43 +0000
Subject: Re: [Linux-ia64] Pre-emption patch for IA-64
Message-Id: <marc-linux-ia64-105590709806122@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 14, 2003 at 02:38:55PM -0700, Bjorn Helgaas wrote:
> On Friday 14 March 2003 2:32 pm, Jesse Barnes wrote:
> > Just FYI, I tried 2.5.64 out on my Bug Sur, and it seems to work ok
> > with the following exceptions:
> >   o the AT keyboard support seems broken (characters are slow to show
> >     up on the screen and are sometimes repeated)
> >   o agp support for 460GX causes a link failure
> 
> 2.4 had a problem that seems to be a compiler issue with some AGP
> code.  I don't know whether this is the same problem, but if it is, I
> applied the following patch as a workaround:

Thanks for the pointer.  Here's a patch against 2.5.64.  It builds and
boots, but my XFree dri/glx/whatever drivers seem broken, so I'm not
sure if it's really working like it should.

Btw Peter, thanks for doing the preemption patch.  No hangs yet for
me...

Jesse


diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64-stock/drivers/char/agp/generic.c linux-2.5.64-ia64/drivers/char/agp/generic.c
--- linux-2.5.64-ia64-stock/drivers/char/agp/generic.c	2003-03-04 19:29:15.000000000 -0800
+++ linux-2.5.64-ia64/drivers/char/agp/generic.c	2003-03-14 14:09:03.000000000 -0800
@@ -34,6 +34,7 @@
 #include <linux/miscdevice.h>
 #include <linux/pm.h>
 #include <linux/agp_backend.h>
+#include <linux/vmalloc.h>
 #include "agp.h"
 
 __u32 *agp_gatt_table; 
@@ -169,26 +170,18 @@
 
 	temp = agp_bridge->current_size;
 
-	switch (agp_bridge->size_type) {
-	case U8_APER_SIZE:
+	if (agp_bridge->size_type = U8_APER_SIZE)
 		current_size = A_SIZE_8(temp)->size;
-		break;
-	case U16_APER_SIZE:
+	else if (agp_bridge->size_type = U16_APER_SIZE)
 		current_size = A_SIZE_16(temp)->size;
-		break;
-	case U32_APER_SIZE:
+	else if (agp_bridge->size_type = U32_APER_SIZE)
 		current_size = A_SIZE_32(temp)->size;
-		break;
-	case LVL2_APER_SIZE:
+	else if (agp_bridge->size_type = LVL2_APER_SIZE)
 		current_size = A_SIZE_LVL2(temp)->size;
-		break;
-	case FIXED_APER_SIZE:
+	else if (agp_bridge->size_type = FIXED_APER_SIZE)
 		current_size = A_SIZE_FIX(temp)->size;
-		break;
-	default:
+	else
 		current_size = 0;
-		break;
-	}
 
 	current_size -= (agp_memory_reserved / (1024*1024));
 	if (current_size <0)
@@ -203,26 +196,18 @@
 
 	temp = agp_bridge->current_size;
 
-	switch (agp_bridge->size_type) {
-	case U8_APER_SIZE:
+	if (agp_bridge->size_type = U8_APER_SIZE)
 		num_entries = A_SIZE_8(temp)->num_entries;
-		break;
-	case U16_APER_SIZE:
+	else if (agp_bridge->size_type = U16_APER_SIZE)
 		num_entries = A_SIZE_16(temp)->num_entries;
-		break;
-	case U32_APER_SIZE:
+	else if (agp_bridge->size_type = U32_APER_SIZE)
 		num_entries = A_SIZE_32(temp)->num_entries;
-		break;
-	case LVL2_APER_SIZE:
+	else if (agp_bridge->size_type = LVL2_APER_SIZE)
 		num_entries = A_SIZE_LVL2(temp)->num_entries;
-		break;
-	case FIXED_APER_SIZE:
+	else if (agp_bridge->size_type = FIXED_APER_SIZE)
 		num_entries = A_SIZE_FIX(temp)->num_entries;
-		break;
-	default:
+	else
 		num_entries = 0;
-		break;
-	}
 
 	num_entries -= agp_memory_reserved>>PAGE_SHIFT;
 	if (num_entries<0)
@@ -546,27 +531,19 @@
 
 	temp = agp_bridge->current_size;
 
-	switch (agp_bridge->size_type) {
-	case U8_APER_SIZE:
+	if (agp_bridge->size_type = U8_APER_SIZE)
 		page_order = A_SIZE_8(temp)->page_order;
-		break;
-	case U16_APER_SIZE:
+	else if (agp_bridge->size_type = U16_APER_SIZE)
 		page_order = A_SIZE_16(temp)->page_order;
-		break;
-	case U32_APER_SIZE:
+	else if (agp_bridge->size_type = U32_APER_SIZE)
 		page_order = A_SIZE_32(temp)->page_order;
-		break;
-	case FIXED_APER_SIZE:
+	else if (agp_bridge->size_type = FIXED_APER_SIZE)
 		page_order = A_SIZE_FIX(temp)->page_order;
-		break;
-	case LVL2_APER_SIZE:
+	else if (agp_bridge->size_type = LVL2_APER_SIZE)
 		/* The generic routines can't deal with 2 level gatt's */
 		return -EINVAL;
-		break;
-	default:
+	else
 		page_order = 0;
-		break;
-	}
 
 	/* Do not worry about freeing memory, because if this is
 	 * called, then all agp memory is deallocated and removed

