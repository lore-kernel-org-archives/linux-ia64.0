From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 03 Nov 2003 21:18:55 +0000
Subject: Re: [PATCH] Bug in sn_pci_map_sg causes MCA
Message-Id: <marc-linux-ia64-106789450614383@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106789192810902@msgid-missing>
In-Reply-To: <marc-linux-ia64-106789192810902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 03, 2003 at 01:14:00PM -0800, David Mosberger wrote:
> >>>>> On Mon, 3 Nov 2003 12:47:55 -0800, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> David, this fixes a critical bug for us.  Can you push it to
>   Jesse> Linus or should we send it straight to Andrew?
> 
> The patch doesn't apply for me, otherwise, I'd have been happy to take
> it (since it's a critical bug fix).  I think it fails to apply because
> TABs got replaced by blanks.

Sorry about that, please try this one.

Jesse

--- /usr/tmp/TmpDir.16109-0/linux/arch/ia64/sn/io/machvec/pci_dma.c_1.5	Mon Nov  3 13:00:46 2003
+++ linux/arch/ia64/sn/io/machvec/pci_dma.c	Mon Nov  3 13:00:27 2003
@@ -279,8 +279,7 @@
 	 * scatterlist.
 	 */
 	for (i = 0; i < nents; i++, sg++) {
-		phys_addr = __pa(sg->dma_address ? sg->dma_address :
-			(unsigned long)page_address(sg->page) + sg->offset);
+		phys_addr = __pa((unsigned long)page_address(sg->page) + sg->offset);
 
 		/*
 		 * Handle the most common case: 64 bit cards.  This
