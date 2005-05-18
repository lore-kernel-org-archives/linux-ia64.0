From: Rolf Eike Beer <eike-hotplug@sf-tec.de>
Date: Wed, 18 May 2005 13:46:31 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <200505181546.31848@bilbo.math.uni-mannheim.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Prarit Bhargava wrote:
> Rolf Eike Beer wrote:

> >>+	num_funcs = pci_scan_slot(slot->pci_bus, PCI_DEVFN(slot->device_num+1,
> >
> > Add spaces before and after '+'. I don't feel good with this "+1" at all,
> > this is some kind of strange.
>
> Aside from being used in the above calculation, the slot->device_num is
> also a bitmask.  The 0th bit corresponds to the first device that is
> active/inactive on a slot.
>
> In the calculation above, the slot we're scanning is PCI_DEVFN(1,0) -- the
> first device in the slot.
>
> I could flip things around and use slot->device_num to a one-based
> calculation, but that leads to more "device_num - 1" statements than
> "device_num" statements in the code.

So "+1" is the better way. Maybe you should write a big comment at the first 
"device_num+1" what magic is going on there. It's likely that someone else 
will come later and will not understand what's going on here, too.

Eike
