From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 20 Nov 2003 17:09:51 +0000
Subject: Re: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-106934835319502@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 19 November 2003 8:28 pm, Matthew Wilcox wrote:
> On Wed, Nov 19, 2003 at 05:33:20PM -0700, Bjorn Helgaas wrote:
> > > 3.alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)
> > 
> > I poked at this again.  The reason this fails is because the
> > VGA console driver starts up very early and allocates ports
> > 0x3c0-0x3df.  It would be nice if we could figure out a way
> > to allocate those ports later, after the PCI bridge has been
> > discovered, so we get the ioport resources correct, but I
> > don't know a reasonable way to do that.
> 
> Ah, I introduced a mechanism for doing the opposite of this in 2.6-test8
> (it's credited to Ben Herrenschmidt since he did the debugging and got
> it merged).  If you call insert_resource() instead of request_resource(),
> conflicting resources get the new resource added as their parent.
> 
> I knew this was going to be handy for more than just PPC ;-)

Nice!  I'll send a patch to Tony for 2.6.1.

