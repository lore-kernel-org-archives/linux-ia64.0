From: Greg KH <greg@kroah.com>
Date: Tue, 24 Jun 2003 22:10:07 +0000
Subject: Re: [PATCH] pcibios_scan_acpi()
Message-Id: <marc-linux-ia64-105649312310740@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105639496518100@msgid-missing>
In-Reply-To: <marc-linux-ia64-105639496518100@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 24, 2003 at 10:31:19PM +0100, Matthew Wilcox wrote:
> On Mon, Jun 23, 2003 at 02:39:05PM -0700, Greg KH wrote:
> > > How about acpi_scan_pci_bus_root()?
> > 
> > I agree, that sounds better.
> 
> I think it's too long ... so unless anyone has a better idea, I'm going with
> pci_acpi_scan_root().  Here's the patch, presented in patch -p1 format to
> make greg's scripts happy ;-)

Thanks you :)

> ia64 needs to be passed the pci domain and the acpi handle corresponding
> to each root bus.  Rather than change pcibios_scan_root to take additional
> arguments, this patch introduces pci_acpi_scan_root().

Looks good, I've applied it.

greg k-h
