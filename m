From: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Date: Fri, 23 Apr 2004 12:21:09 +0000
Subject: Re: [Pcihpd-discuss] [RFC] New sysfs tree for hotplug
Message-Id: <20040423212109.1cd9092c.tokunaga.keiich@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040415170939.0ff62618.tokunaga.keiich@jp.fujitsu.com>
 <20040416223436.GB21701@kroah.com> <20040416233944.GF24556@cup.hp.com>
In-Reply-To: <20040416233944.GF24556@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: tokunaga.keiich@jp.fujitsu.com, lhcs-devel@lists.sourceforge.net, lhms-devel@lists.sourceforge.net, linux-hotplug-devel@lists.sourceforge.net, pcihpd-discuss@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, acpi-largesys-devel@lists.sourceforge.net

Hi Grant,

Thanks for the comments:)

Grant wrote:
> On Fri, Apr 16, 2004 at 03:34:36PM -0700, Greg KH wrote:
> > >  Recent large machines have many PCI devices and some boards that
> > > contain devices (e.g. CPU, memory, and/or I/O devices).  A certain PCI
> > > device (PCI1) might be connected with other one (PCI2), which means that
> > > there is a dependency between PCI1 and PCI2.
> > 
> > You have this today?
> 
> I interpreted his comments to mean PCI-PCI Bridges.
> eg something like a 4-port NIC which usually has a PCI-PCI bridge
> to "isolate" multiple PCI devices (NICs):
>  +-[60]---01.0-[61]--+-04.0  Digital Equipment Corporation DECchip 21142/43
>  |                   +-05.0  Digital Equipment Corporation DECchip 21142/43
>  |                   +-06.0  Digital Equipment Corporation DECchip 21142/43
>  |                   \-07.0  Digital Equipment Corporation DECchip 21142/43
> ...
> 
> I thought this was already handled though so I may be misunderstanding.
> Keiichiro, an example would be very helpful in understanding.

As in an email I sent to Greg, P2P bridge that has hotpluggable slots need
to be represented in a hierarchy style.  I don't think that kind of P2P bridge
is handled yet.
 
Thanks,
Kei
