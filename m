From: Mike Smith <msmith@freebsd.org>
Date: Sat, 18 Nov 2000 07:52:18 +0000
Subject: Re: [Linux-ia64] ACPI 2.0 support
Message-Id: <marc-linux-ia64-105590678205749@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205743@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205743@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>    I'd also like to incorporate using ACPI methods to get resource
> information for programming PCI devices, eventually leading to
> support for hot-plug PCI via ACPI.  Anyone have any thoughts or
> interest there?  Thanks,

I hope folks don't mind a stranger dropping in on this discussion; I've 
been doing similar work for the IA32 and IA64 FreeBSD codebase though and 
this is a point I've been looking at for a while.

The key item to bear in mind here is that ACPI stays out of the way of 
other enumeration mechanisms; meaning that ACPI itself isn't going to 
help you very much when it comes to resource information for 
newly-arrived PCI devices, other than routing interrupts for them (and 
even then your bridge driver will still have to correctly swizzle for 
devices on the other side of the bridge).

I've written (but not verified) code that uses the Intel ACPI CA codebase 
to route PCI interrupts for the host-PCI bridge; I'd be happy to furnish 
this on request, although in truth the documentation is enough to make 
this a largely trivial task.

As for allocating memory ranges and configuring intermediate bridges; 
ACPI doesn't play a role here at all (so far as I've seen, at any rate).

Hope this helps.

Mike

-- 
... every activity meets with opposition, everyone who acts has his
rivals and unfortunately opponents also.  But not because people want
to be opponents, rather because the tasks and relationships force
people to take different points of view.  [Dr. Fritz Todt]
           V I C T O R Y   N O T   V E N G E A N C E



