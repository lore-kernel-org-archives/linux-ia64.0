From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 13 Aug 2004 15:32:03 +0000
Subject: Re: interrupt locality for NUMA
Message-Id: <200408130832.03760.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1092365888.6434.25.camel@localhost.localdomain>
In-Reply-To: <1092365888.6434.25.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, August 12, 2004 7:58 pm, Alex Williamson wrote:
>    This probably isn't ready for inclusion yet, but I wanted to see if
> anybody else could make use of it.  This works on HP sx1000 boxes setup
> for NUMA and I think it's ACPI namespace does the right thing.  All this
> does is walk through namespace looking for devices with an _MAT method
> that returns an IOSAPIC and also has a _PXM method to tell us the
> proximity domain where it lives.  The node data gets stored in the
> iosapic data structure because doing this lookup is pretty slow.  Does
> this jive with what other ACPI NUMA boxes are exporting in namespace?
> I'm hoping everyone will put the _PXM on the same device as the _MAT,
> but I'm wondering if I need to add support for looking on parent
> objects.  Thoughts?  Thanks,

Matt Dobson is working on a pci_to_nodemask, might that be used instead?  If 
we did it that way, we could put it in generic code, dependent on CONFIG_NUMA 
or something, rather than keeping it ACPI specific.

Jesse
