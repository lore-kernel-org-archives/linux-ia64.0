From: Greg KH <greg@kroah.com>
Date: Thu, 24 Oct 2002 06:12:36 +0000
Subject: [Linux-ia64] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805225@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 23, 2002 at 10:59:34PM -0700, KOCHI, Takayoshi wrote:
> Hi,
> 
> On Wed, 23 Oct 2002 22:10:08 -0700
> Greg KH <greg@kroah.com> wrote:
> 
> > Also, why doesn't the ACPI PCI hotplug driver work for your machines?
> > I've seen it work on a very wide range of processors (i386 and ia64),
> > and manufacturers, and any specific issues with your hardware would
> > probably be better addressed with patches to the existing ACPI driver.
> 
> The ACPI spec provides very limited control of actual hardware
> (With ACPI, we don't have common method for controlling such as Bus
> speed, LED etc.).
> So if a hardware comes with well-documented hotplug controller, we
> can achieve finer control over the hardware.

Ah, I didn't realize this.  So for some machines (like IBM's x440), we
should stick with using the hotplug controller driver, instead of using
the ACPI driver.  Sounds reasonable to me.

> The SHPC specification defines it still depends on ACPI for managing
> resources, etc.  So resource management portion can be and *should be*
> shared with all PCI hotplug drivers that use ACPI for resource
> management.
> 
> I think the most important thing is everyone agree on the direction
> in which we should go before we code anything, in order not to waste
> our time.

I think we now all agree that resource management should move into a
place where it can be shared by all pci hotplug drivers, right?

If so, anyone want to propose some common code?  I think the stuff in
the ACPI driver that was pulled from the Compaq driver is a great start.
I can try to pull this into the core myself, but if the Intel developers
have the time, and energy, I would greatly appreciate their help (or
anyone else who wants to join in.)

thanks,

greg k-h

