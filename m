From: Grant Grundler <iod00d@hp.com>
Date: Fri, 16 Apr 2004 23:39:44 +0000
Subject: Re: [Pcihpd-discuss] [RFC] New sysfs tree for hotplug
Message-Id: <20040416233944.GF24556@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040415170939.0ff62618.tokunaga.keiich@jp.fujitsu.com> <20040416223436.GB21701@kroah.com>
In-Reply-To: <20040416223436.GB21701@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>, lhcs-devel@lists.sourceforge.net, lhms-devel@lists.sourceforge.net, linux-hotplug-devel@lists.sourceforge.net, pcihpd-discuss@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, acpi-largesys-devel@lists.sourceforge.net

On Fri, Apr 16, 2004 at 03:34:36PM -0700, Greg KH wrote:
> >  Recent large machines have many PCI devices and some boards that
> > contain devices (e.g. CPU, memory, and/or I/O devices).  A certain PCI
> > device (PCI1) might be connected with other one (PCI2), which means that
> > there is a dependency between PCI1 and PCI2.
> 
> You have this today?

I interpreted his comments to mean PCI-PCI Bridges.
eg something like a 4-port NIC which usually has a PCI-PCI bridge
to "isolate" multiple PCI devices (NICs):
 +-[60]---01.0-[61]--+-04.0  Digital Equipment Corporation DECchip 21142/43
 |                   +-05.0  Digital Equipment Corporation DECchip 21142/43
 |                   +-06.0  Digital Equipment Corporation DECchip 21142/43
 |                   \-07.0  Digital Equipment Corporation DECchip 21142/43
...

I thought this was already handled though so I may be misunderstanding.
Keiichiro, an example would be very helpful in understanding.

...
> Hm, no.  What about usb, firewire, scsi and any other future bus that
> can be "hotpluggable".  The kernel doesn't treat them differently, and
> we shouldn't either.

SCSI has a heirarchy as well. Ie LUNs can be removed without
removing the target (RAID controllers). Normal JBOD use equates
LUNs and targets.

grant
