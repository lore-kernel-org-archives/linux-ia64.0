From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 14 Mar 2003 21:38:55 +0000
Subject: Re: [Linux-ia64] Pre-emption patch for IA-64
Message-Id: <marc-linux-ia64-105590709806117@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 14 March 2003 2:32 pm, Jesse Barnes wrote:
> Just FYI, I tried 2.5.64 out on my Bug Sur, and it seems to work ok
> with the following exceptions:
>   o the AT keyboard support seems broken (characters are slow to show
>     up on the screen and are sometimes repeated)
>   o agp support for 460GX causes a link failure

2.4 had a problem that seems to be a compiler issue with some AGP
code.  I don't know whether this is the same problem, but if it is, I
applied the following patch as a workaround:

diff -Nru a/drivers/char/agp/agpgart_be.c b/drivers/char/agp/agpgart_be.c
--- a/drivers/char/agp/agpgart_be.c	Fri Mar 14 14:22:45 2003
+++ b/drivers/char/agp/agpgart_be.c	Fri Mar 14 14:22:45 2003
@@ -341,26 +341,18 @@
 
 	temp = agp_bridge.current_size;
 
-	switch (agp_bridge.size_type) {
-	case U8_APER_SIZE:
+	if (agp_bridge.size_type = U8_APER_SIZE)
 		current_size = A_SIZE_8(temp)->size;
-		break;
-	case U16_APER_SIZE:
+	else if (agp_bridge.size_type =  U16_APER_SIZE)
 		current_size = A_SIZE_16(temp)->size;
-		break;
-	case U32_APER_SIZE:
+	else if (agp_bridge.size_type =  U32_APER_SIZE)
 		current_size = A_SIZE_32(temp)->size;
-		break;
-	case LVL2_APER_SIZE:
+	else if (agp_bridge.size_type =  LVL2_APER_SIZE)
 		current_size = A_SIZE_LVL2(temp)->size;
-		break;
-	case FIXED_APER_SIZE:
+	else if (agp_bridge.size_type =  FIXED_APER_SIZE)
 		current_size = A_SIZE_FIX(temp)->size;
-		break;
-	default:
+	else
 		current_size = 0;
-		break;
-	}
 
 	current_size -= (agp_memory_reserved / (1024*1024));
 


