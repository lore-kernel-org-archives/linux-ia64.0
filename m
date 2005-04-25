From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 25 Apr 2005 16:01:08 +0000
Subject: Re: [PATCH 2.6.12 1/1] pcdp: add PCDP pci interface support
Message-Id: <200504251001.08050.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
In-Reply-To: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 25 April 2005 9:34 am, Mark Maule wrote:
> > This looks good to me, except that I think we should remove the
> > EFI_PCDP references below.  The idea of supporting multiple VGA
> > devices is completely orthogonal to the PCDP.
> 
> Ok, so you suggest just making vga_console_membase/vga_console_iobase
> unconditionally declared and used, and then optionally modified if
> CONFIG_EFI_PCDP is defined?

Yes.
