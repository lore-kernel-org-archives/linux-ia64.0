From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 11 Aug 2005 20:37:46 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <200508111437.46958.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com> <20050811203437.GA9265@infradead.org>
In-Reply-To: <20050811203437.GA9265@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org

On Thursday 11 August 2005 2:34 pm, Christoph Hellwig wrote:
> On Thu, Aug 11, 2005 at 02:24:43PM -0600, Bjorn Helgaas wrote:
> > IA64 boxes only have PCI IDE devices, so there's no need to blindly poke
> > around in I/O port space.  Poking at things that don't exist causes MCAs
> > on HP ia64 systems.
> 
> Maybe it should instead depend on those systems where it is available.
> Anything but X86?

I'm OK with that, but don't want to be responsible for coming up
with the list of systems where it should be available :-)
