From: "Scott Murray" <scottm@somanetworks.com>
Date: Thu, 24 Oct 2002 22:22:44 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805242@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805235@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805235@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 24 Oct 2002, Greg KH wrote:

> On Thu, Oct 24, 2002 at 01:44:06PM -0400, Scott Murray wrote:
> >
> > I don't know if you looked at my cPCI driver patch in detail, but it uses
> > the setup-*.c code for all of its resource management.
>
> I'm sorry, but I only glanced at it and missed this point.

No problemo, I kind of vanished off the face of the earth after my last
mention of releasing a 2.5 patch, which was over a month and a half ago.
Now that we've got our new hardware platform up and running here at SOMA,
I'm back in a position to work on hotplug stuff again.

> > The only things that were really missing in 2.4.x were:
> >
> > - exports of a few things, most notably pci_scan_bridge
> > - code to update the resource windows of a newly added bridge (recursively)
> > - a pci_write_bridge_bases
> > - PCI resource reservation to allow hot insertion on dumb cPCI hardware
> > - on x86, the smarts to work back to the root PCI bus to figure out the
> >   IRQ pin to use when looking in the pirq table
>
> All of these seem like things that should belong in the setup-*.c files
> for others to use.

I think Ivan's new code in setup-bus.c (pbus_size_bridges and friends)
removes the need for a pci_write_bridge_bases and my code to update the
bridge resource windows.  I hope so, since I've changed my driver to use
it! ;)

> > Since I've been swamped with other stuff, I just started finally porting
> > my cPCI stuff to 2.5 yesterday. :(  I think I can get it up and running
> > relatively quickly, but figuring out Ivan's newer hotplug helper code
> > and how to take advantage of it might take me a couple of days.
>
> Nice, I was wondering what happened.  I'll go dig up your older patch
> and take a closer look at it.

I hopefully will have something working against 2.5.44 tomorrow.  I think
the only potentially contentious piece that I'd like to get reviewed and
maybe integrated before the feature freeze is the resource reservation
stuff.  There seemed to be no serious objections to the 2.4.x version I
posted a while back, so maybe this won't be a big deal.  Everything else
is either __devinit/export tweaks or driver code.

Scott


-- 
Scott Murray
SOMA Networks, Inc.
Toronto, Ontario
e-mail: scottm@somanetworks.com


