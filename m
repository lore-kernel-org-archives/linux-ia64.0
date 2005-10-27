From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 27 Oct 2005 07:10:58 +0000
Subject: Re: [PATCH] kexec on ia64
Message-Id: <m1acgvcu4d.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> On Wed, Oct 26, 2005 at 02:25:56PM -0600, Eric W. Biederman wrote:
>> Interesting.  This should be a decision made by kexec-tools,
>> not by the kernel.  On x86 the kernel just verifies we load the
>> crash kernel into the reserved chunk of the address space.  I haven't
>> looked closely enough to see if the architecture part has fixed
>> address assumptions yet.  
>> 
>> Tony what were you seeing that made you conclude that the code
>> would always load over the existing kernel?
>
> Ok .. kexectools should be able to make a decision about where to load the
> new kernel based on what it finds in /proc/iomem (and in the Elf header
> of the new kernel).  I don't know enough Elf (elvish? :-) to know
> whether the Elf header we currently generate for a kernel describes
> things in a way that would convey that it is OK to drop the image
> at any (suitably aligned) address, or whether there will have to be
> some ia64 specific magic in the kexectools to choose the load address.

I don't think ld can be talked into setting ET_REL instead ET_EXEC right
now, without building as a shared library.  (readelf -a on the kernel
will tell you) but since that is a general problem it is likely worth
an extra flag to /sbin/kexec to tell it to assume an ELF executable is
relocatable even if it doesn't say ET_REL.

>> I also didn't see the trivial patch to put the 32bit compat support
>> in.  It's not terribly important or useful but there is no reason
>> not to include it.
>
> Usefullness is a key here.  The kexectools definitely include some
> architecture specific components.  So taking the x86 version of the
> "kexec" binary onto an ia64 system isn't going to be very useful even
> if the kernel did happen to have an ia32 entry point for kexec
> enabled.  Building an ia32 binary, but with all the ia64 specific
> parts enabled would seem to be _challenging_ (Nanhai's version has
> purgatory/arch/ia64/entry.S!).  Perhaps there might be a better outlet
> for that much creativity? [Which is another way of saying that I'm
> not interested in seeing a patch to enable the ia32 kexec entry point
> on ia64 ... so don't waste any time creating one].

I know of at least one application that before it flashes your rom
chip checks to see if you have kexec in your kernel.  And it does
that by calling sys_kexec and seeing if it gets -EINVAL instead
of -ENOSYS.  At least with kexec present it knows that if something
terribly goes wrong it has the chance to load another kernel, in the
event the mtd drivers in the kernel don't handle some subtle hardware
bug.  That application can safely be distributed as a 32bit binary
on i386, x86_64, and ia64.

I'm not quite certain what the build issues that would be involved
but it wouldn't surprise one of the architectures that normally run
a 32bit user space with a 64bit kernel happened to solve the issue.
So I only expect to use the code that comes pretty much for free.

The kernel side of the implementation already exists and I suspect
it is as useful as any other ia32 compat syscall entry point on the 
ia64 kernel.  I care as this is a completeness issue and I don't
see a reason not to enable the kernel side.

Eric
