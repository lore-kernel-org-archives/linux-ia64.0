From: Alex Williamson <awilliam@fc.hp.com>
Date: Mon, 20 Nov 2000 16:00:46 +0000
Subject: Re: [Linux-ia64] ACPI 2.0 support
Message-Id: <marc-linux-ia64-105590678205754@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205743@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205743@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike Smith wrote:
> 
> >    I'd also like to incorporate using ACPI methods to get resource
> > information for programming PCI devices, eventually leading to
> > support for hot-plug PCI via ACPI.  Anyone have any thoughts or
> > interest there?  Thanks,
> 
> I hope folks don't mind a stranger dropping in on this discussion; I've
> been doing similar work for the IA32 and IA64 FreeBSD codebase though and
> this is a point I've been looking at for a while.
> 
> The key item to bear in mind here is that ACPI stays out of the way of
> other enumeration mechanisms; meaning that ACPI itself isn't going to
> help you very much when it comes to resource information for
> newly-arrived PCI devices, other than routing interrupts for them (and
> even then your bridge driver will still have to correctly swizzle for
> devices on the other side of the bridge).
> 
> I've written (but not verified) code that uses the Intel ACPI CA codebase
> to route PCI interrupts for the host-PCI bridge; I'd be happy to furnish
> this on request, although in truth the documentation is enough to make
> this a largely trivial task.
> 
> As for allocating memory ranges and configuring intermediate bridges;
> ACPI doesn't play a role here at all (so far as I've seen, at any rate).
> 

   Not yet ;)  They key thing to remember here is that the resources
available to a PCI bus are typically static, even if PCI devices can be
inserted and removed.  So, the _CRS/_PRS methods should be able to
provide the necessary resource information for newly inserted PCI
devices.  This will, of course, be dependent on the ACPI firmware vendor
doing a sufficient implementation and the system providing sufficient
MMIO/IO port space for added devices on each PCI bus.  If ACPI won't
work for us in determining valid PCI resources, then what chipset
independent mechanism do we have?  As we move to systems designed with
more high availability features, I see firmware playing less of a
role in actually programming the resource registers on PCI devices.
Firmware will likely lean more towards providing mechanisms by which the
OS can do it on it's own.

	Alex

--
Alex Williamson                                  Linux Development Lab
awilliam@fc.hp.com                                     Hewlett Packard
970-898-9173                                          Fort Collins, CO

