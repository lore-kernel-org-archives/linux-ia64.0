From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 27 Aug 2004 15:36:54 +0000
Subject: Re: Latest Altix I/O code reorganization code
Message-Id: <20040827163654.A32236@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <20040806141836.A9854@infradead.org> <411AAABB.8070707@sgi.com> <412F4EC9.7050003@sgi.com>
In-Reply-To: <412F4EC9.7050003@sgi.com>; from pfg@sgi.com on Fri, Aug 27, 2004 at 10:10:01AM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 27, 2004 at 10:10:01AM -0500, Patrick Gefre wrote:
> io_init.c  iomv.c  Makefile  pci  pci_dma.c  pci_extension.c
> 
> arch/ia64/sn/ioif/pci:
> Makefile  pcibr_ate.c  pcibr_dma.c  pcibr_provider.c  pcibr_reg.c  xtalk_providers.c
> 

So why are pci_dma.c and pci_extensions.c not under pci?  You probably should
just kill that pci subdir, too when there's just two other files left.  Or
move those two to kernel/ and have a pci/ subdir which seems to fit other
ports quite well.  But I'd rather see the functional changes first and then
do renaming of unchanged files last anyway so you changed get actually
reviewable.  The current patchkit is not.


