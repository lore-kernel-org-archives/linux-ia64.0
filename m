From: Ralf Baechle <ralf@linux-mips.org>
Date: Wed, 24 Aug 2005 22:49:29 +0000
Subject: Re: [PATCH 05/15] ia64: remove use of asm/segment.h
Message-Id: <20050824224929.GB2714@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0508241139100.23956@nylon.am.freescale.net> <Pine.LNX.4.61.0508241152380.23956@nylon.am.freescale.net> <200508241409.55570.bjorn.helgaas@hp.com>
In-Reply-To: <200508241409.55570.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Kumar Gala <galak@freescale.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Wed, Aug 24, 2005 at 02:09:55PM -0600, Bjorn Helgaas wrote:

> On Wednesday 24 August 2005 10:53 am, Kumar Gala wrote:
> > Removed IA64 architecture specific users of asm/segment.h and
> > asm-ia64/segment.h itself
> 
> I posted a similar patch a month ago, but I only removed the
> arch/ia64 includes of asm/segment.h.
> 
> There are still a few drivers that include asm/segment.h, so
> I don't think we should remove asm/segment.h itself just yet.

<asm/segment.h> was replaced by <asm/uaccess.h> in 2.1.4 and we still have
references ...

  Ralf
