From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 23 Jun 2003 15:04:43 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105638090201213@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:
> 
> There might well be. It's easy to get the block merging code
> wrong when merging random chunks which can be bigger or smaller
> than PAGE_SIZE. My gut feeling this can all get ripped out of
> 2.5 sba_iommu.c if the bio code is going to merge for us. That
> means pci_map_sg() support only needs to map each address/len
> pair and forget trying to merge them.

   I don't think the bio code is doing a sufficient level of
merging to rip the coalescing out of sba_iommu.  Running w/
some debugging turned on and the bio code enabled, I'm
regularly seeing long sg lists get colapsed (99 to 1 is not
terribly uncommon).

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab
