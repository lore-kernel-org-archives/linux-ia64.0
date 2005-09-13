From: Khalid Aziz <khalid.aziz@hp.com>
Date: Tue, 13 Sep 2005 22:47:27 +0000
Subject: Re: [RFC] /proc/efi_memmap
Message-Id: <1126651647.29344.31.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
In-Reply-To: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-09-13 at 12:30 -0700, Luck, Tony wrote:
> On Tue, Sep 13, 2005 at 10:05:03AM -0600, Khalid Aziz wrote:
> > The userspace kexec tools looks at the memory map to verify a new kernel
> > being loaded in memory will be loaded in memory that is normally
> > available for it. Same goes for initial ramdisk as well. kexec
> > opens /proc/iomem on x86 for this. I had sent a patch in July (subject
> > "[PATCH] /proc/iomem update") that provides same info in /proc/iomem as
> > x86 does and that will take care of kexec needs. I have already tested
> > kexec tool for ia64 with that patch and it works fine.
> 
> I should dust that off and take a look at it.  /proc/iomem seems a curious
> name for a file that contains this information.

It may have evolved from its original use. On x86, it currently seems to
give information about full memory space. David pointed out a bug in the
last patch I had sent out. I found another bug in that patch this
morning which I have fixed now. I am running a few tests on it. I will
send out updated patch tomorrow.

> 
> So what is the current state of kexec for ia64?  I think that there
> are two modes of operation:
> 
> 1) Fast reboot (bypasses f/w ... which takes a significant amount of
>    the reboot time).
> 
> 2) A means to getting a running kernel to take a crash dump.
> 
> In case 1, the system is still running ... so kexec can load the new
> kernel from disk, and arrange for an orderly transfer of control from
> the old kernel to the new.
> 
> In case 2, we need to plan ahead, and have the new kernel pre-loaded
> into some reserved memory so when the panic hits (or the INIT button
> is pressed) we don't need to do any I/O or memory allocation.  We just
> leap to the new kernel.  For this case ia64 would appear to have an
> advantage over other architectures ... we don't need to locate the new
> kernel at any particular address, so we can leave the original kernel
> untouched while we boot just using the reserved block of memory.
> 
> What's working?  What's still being developed?  Can we get this into
> shape for 2.6.15?
> 
> -Tony

I am testing my patch for 2.6.13 kernel. I will try to send it out next
week. A normal reboot using kexec (your case 1) works very reliably. I
have done 9000 back to back kexec reboots bypassing firmware each time
successfully. I have case 2 working as well. If a kernel is pre-loaded,
a pnic or INIT automatically causes a kexec reboot.

-- 
Khalid

==================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

