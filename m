From: Matthew Wilcox <willy@debian.org>
Date: Wed, 17 Dec 2003 12:23:20 +0000
Subject: Re: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107166381724629@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 17, 2003 at 10:54:09AM +0800, Yu, Luming wrote:
> >> I think  "To bus device, resources returned from _CRS method means that bus device will
> >> supply those resouces to its children devices. So it's unreasonable to call
> >> request_resource for them."
> 
> >That's faulty logic.  Resources can either be busy (used at the leaf
> >by a driver) or merely containers for other resources (as they are in
> >this case).
> 
> My concern is that if a device driver want to request a resource,
> but that resource has been allocated by bus device (which supply this resources to its children devices) 
> then  -EBUSY get returned. Maybe device driver can
> ignore this error.  But how to detect a real resource conflict  with other device (another resource consumer)?  All of them return -EBUSY.

No, you don't understand how resources work.  When device drivers request
them, they're marked as busy.  When busses claim them, they're marked
as not-busy.  Take a look at __request_region in kernel/resource.c.
It checks IORESOURCE_BUSY to see whether it can have the new resource
as a child of the existing one.

> > For example, when
> >PCI needs to allocate resources, if we don't partition the root resource
> >amongst the child busses, we could inadvertently allocate resources that
> >straddle two PCI busses, and that just won't work.
> 
> All resources info returned from _CRS has been saved in pci_root_info->controller->window.  Is it enough?

No, the generic PCI code knows nothing about this ACPI-specific
information.  It relies on the resources being set up correctly.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
