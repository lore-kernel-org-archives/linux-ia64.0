From: Mark Maule <maule@sgi.com>
Date: Mon, 25 Apr 2005 15:34:35 +0000
Subject: Re: [PATCH 2.6.12 1/1] pcdp: add PCDP pci interface support
Message-Id: <Pine.SGI.3.96.1050425103040.39439805J-100000@daisy-e236.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
In-Reply-To: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 25 Apr 2005, Bjorn Helgaas wrote:

> On Saturday 23 April 2005 12:00 pm, Mark Maule wrote:
> > Resend with changes per Bjorn Helgaas comments.  Changes from original:
> > 
> > + Change globals to vga_console_iobase/vga_console_membase.
> > + Address style-related comments.
> 
> This looks good to me, except that I think we should remove the
> EFI_PCDP references below.  The idea of supporting multiple VGA
> devices is completely orthogonal to the PCDP.

Ok, so you suggest just making vga_console_membase/vga_console_iobase
unconditionally declared and used, and then optionally modified if
CONFIG_EFI_PCDP is defined?

thanks
Mark

