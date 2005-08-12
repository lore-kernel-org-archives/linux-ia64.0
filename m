From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 12 Aug 2005 08:40:12 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <1123836012.22460.16.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com>
In-Reply-To: <200508111424.43150.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org

On Iau, 2005-08-11 at 14:24 -0600, Bjorn Helgaas wrote:
> IA64 boxes only have PCI IDE devices, so there's no need to blindly poke
> around in I/O port space.  Poking at things that don't exist causes MCAs
> on HP ia64 systems.
> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Nak-by: Alan Cox <alan@redhat.com>

Assuming all IA-64 boxes are PCI or better then you actually want to
edit include/asm-ia64/ide.h and edit ide_default_io_base where someone
years ago cut and pasted x86-32 values so that case 2-5 are removed.
Then you will just probe the compatibility mode PCI addresses for system
IDE channels.


