From: Greg KH <greg@kroah.com>
Date: Wed, 18 Jun 2003 22:30:03 +0000
Subject: Re: ACPI vs PCI: configuration space
Message-Id: <marc-linux-ia64-105597551609149@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105597468808360@msgid-missing>
In-Reply-To: <marc-linux-ia64-105597468808360@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 18, 2003 at 11:17:52PM +0100, Matthew Wilcox wrote:
> 
> It's kind of annoying to invent some structures and put some values into
> them only to pull them out again.  This leads to try 5 ...
> 
> struct acpi_pci_ops {
> 	int (*read)(int domain, int bus, int devfn, int where, int size, u32 *val);
> 	int (*write)(int domain, int bus, int devfn, int where, int size, u32 val);
> }
> 
> It reduces stack consumption, which is a clear win ... it's also _incredibly_
> easy to implement since all the existing pci_ops call functions which take
> exactly this form.
> 
> Go on, approve Try 5.  You know you want to ;-)

So for i386, what would domain be?

Anyway, yeah, I agree with try 5, that seems the most sane.

thanks,

greg k-h
