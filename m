From: "Scott Murray" <scottm@somanetworks.com>
Date: Thu, 24 Oct 2002 17:44:06 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805235@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 24 Oct 2002, Greg KH wrote:

> On Thu, Oct 24, 2002 at 10:52:09AM -0400, Jeff Garzik wrote:
> > Greg KH wrote:
> > >I think we now all agree that resource management should move into a
> > >place where it can be shared by all pci hotplug drivers, right?
> > >
> > >If so, anyone want to propose some common code?
> >
> >
> > drivers/pci/setup* is not enough?
> >
> > I am surprised that anything needed to be added here...
>
> There was some reason that code would not work out when I looked at it
> over a year ago.  But I don't remember why, so I'll go look at it again,
> thanks for pointing it out.

I don't know if you looked at my cPCI driver patch in detail, but it uses
the setup-*.c code for all of its resource management.  The only things
that were really missing in 2.4.x were:

- exports of a few things, most notably pci_scan_bridge
- code to update the resource windows of a newly added bridge (recursively)
- a pci_write_bridge_bases
- PCI resource reservation to allow hot insertion on dumb cPCI hardware
- on x86, the smarts to work back to the root PCI bus to figure out the
  IRQ pin to use when looking in the pirq table

Since I've been swamped with other stuff, I just started finally porting
my cPCI stuff to 2.5 yesterday. :(  I think I can get it up and running
relatively quickly, but figuring out Ivan's newer hotplug helper code
and how to take advantage of it might take me a couple of days.

Scott


-- 
Scott Murray
SOMA Networks, Inc.
Toronto, Ontario
e-mail: scottm@somanetworks.com


