From: "Grover, Andrew" <andrew.grover@intel.com>
Date: Fri, 02 Mar 2001 23:30:18 +0000
Subject: RE: [Linux-ia64] CONFIG_IA64_L1_CACHE_SHIFT
Message-Id: <marc-linux-ia64-105590693005243@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005236@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005236@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

Please see the detailed response below. (Sorry for the length, but you raise
a lot of issues.)

-- Andy

>   Jes> Btw. shouldn't the acpi code use SMP_CACHE_BYTES for alignment?
>   Jes> It doesn't buy you a whole lot to align on L1 cache boundaries
>   Jes> if you're trying to be SMP aware - or is it rather a DMA vs CPU
>   Jes> alignment issue?
> 
> I don't know.  Not to hurt any feelings, but the ACPI code is a
> monstrous piece of software that strikes me as being very poorly
> integrated into the Linux kernel.  It seems to redo everything on its
> own and does so often more poorly than if it were to use the existing
> facilities.  Case in point: it defines its own unaligned access macros
> in acmacros.h even though such a facility already is provided in
> <asm/unaligned.h>.  Of course, the stuff provided in <asm/unaligned.h>
> does the Right Thing, unlike the macros defined in acmacros.h.  Sigh.
> 
> My suspicion is that the acpi code is also needlessly complex.  The
> ACPI spec obviously doesn't help things (must be the worst spec ever
> written), but I think the whole situation is not unlike USB: a poor
> spec is likely to lead to a poor implementation, but that doesn't mean
> it can't be implemented cleanly.  The question is of course whether
> someone cares enough to attempt to either clean up the existing
> implementation or re-implement the entire thing from scratch.

It would probably help for you to understand where this code comes from. The
ACPI code we contribute is a "Linuxized" version of Intel's ACPI component
architecture (ACPI CA) source. ACPI CA is integrated into many operating
systems and supports 16-bit, 32-bit, and 64-bit environments. As such,
certain modularizations must be done to make sure it can be easily ported to
all of the environments. For example, the clib is not linked to the kernel
so we need to provide the functions that we need. This is why we define our
own alignment macros. While we maintain the ACPI CA code, we have to keep it
this way so that all ACPI CA users can benefit from development and bug
fixes. This includes the FreeBSD folks who are forging ahead of Linux, and
many of the IA-64 Unix OS vendors.

In the future, when we have achieved certain functional power management
milestones under Linux and a significant number of developers have come to
understand the complexity of the ACPI subsystem, it makes sense that the
code be optimized explicitly for the target OS environment. We expect that
this will happen over time for each OS vendor - the OS vendor should start
maintaining and advancing their OS specific ACPI implementation. In the mean
time, we need to keep it like it is. Take a look at the Unix-based or
Window-based dev environment ACPI CA code at:
http://developer.intel.com/technology/iapc/acpi/downloads.htm and see if
that looks any better to you. This code is run through a source formatting
program (linuxizer) before we contribute it. Linus inspected and approved
the output for use in the Linux kernel.

Although the code is complex, we do not feel that it is "needlessly
complex".  ACPI encompasses a great deal - far more than just simple power
management.  The ACPI work is a major effort. If it wasn't, we would not
have had to do it - meaning no one other than MS and one other OS vendor
attempted it (the FreeBSD folks). We've been working on it for between 5-7
man-years at this point and there is still significant effort to come --
both in changes to the Linux driver model and dynamic device enumeration and
configuration enhancements that need to be undertaken before we can really
get Linux-based systems to survive a transition from wake to sleep to wake
again. It is complex because its problem domains are complex and varied.

It's hard code to jump in and understand because one needs such a large
background to understand all the ACPI-isms. I hope this helps you and others
understand more about why the code is like it is. It should probably also be
moved out of the drivers directory into a core os component directory of its
own because it's not really a driver.  In the future, changes will be
necessary to Linux32 in like manner that they have been made to Linux64 to
support the initialization of systems without an APM/MPS/PnPBIOS legacy.
When the OS finally can enumerate and load drivers for motherboard-based
devices using the ACPI namespace, things will need to look much different.
In the mean time, we teeter on the edge of providing power management with
the ACPI support and static legacy based support of non-ACPI devices.

That said, if you find something wrong or lacking in the code (such as the
alignment macros) - please inform us so that we can fix the problem - a
patch would be even better. We care enough to do a correct implementation,
but we have a lot of work on our plate right now.

Regards -- Andy


