From: Matthew Wilcox <willy@debian.org>
Date: Thu, 24 Oct 2002 11:49:52 +0000
Subject: Re: [Linux-ia64] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805227@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 23, 2002 at 11:12:36PM -0700, Greg KH wrote:
> I think we now all agree that resource management should move into a
> place where it can be shared by all pci hotplug drivers, right?
> 
> If so, anyone want to propose some common code?  I think the stuff in
> the ACPI driver that was pulled from the Compaq driver is a great start.
> I can try to pull this into the core myself, but if the Intel developers
> have the time, and energy, I would greatly appreciate their help (or
> anyone else who wants to join in.)

We already _have_ a lot of common code in drivers/pci, but it's not
compiled in for x86 or ia64.  some other architectures don't assign PCI
resources in the `BIOS' so we get to do it.  setup-bus.c, setup-res.c
and setup-irq.c all seem to duplicate some part of the code currently
found in each and every hotplug driver.

-- 
Revolutions do not require corporate support.

