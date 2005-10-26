From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 26 Oct 2005 21:43:40 +0000
Subject: Re: [PATCH] kexec on ia64
Message-Id: <20051026214340.GA6038@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 26, 2005 at 02:25:56PM -0600, Eric W. Biederman wrote:
> Interesting.  This should be a decision made by kexec-tools,
> not by the kernel.  On x86 the kernel just verifies we load the
> crash kernel into the reserved chunk of the address space.  I haven't
> looked closely enough to see if the architecture part has fixed
> address assumptions yet.  
> 
> Tony what were you seeing that made you conclude that the code
> would always load over the existing kernel?

Ok .. kexectools should be able to make a decision about where to load the
new kernel based on what it finds in /proc/iomem (and in the Elf header
of the new kernel).  I don't know enough Elf (elvish? :-) to know
whether the Elf header we currently generate for a kernel describes
things in a way that would convey that it is OK to drop the image
at any (suitably aligned) address, or whether there will have to be
some ia64 specific magic in the kexectools to choose the load address.

> I also didn't see the trivial patch to put the 32bit compat support
> in.  It's not terribly important or useful but there is no reason
> not to include it.

Usefullness is a key here.  The kexectools definitely include some
architecture specific components.  So taking the x86 version of the
"kexec" binary onto an ia64 system isn't going to be very useful even
if the kernel did happen to have an ia32 entry point for kexec
enabled.  Building an ia32 binary, but with all the ia64 specific
parts enabled would seem to be _challenging_ (Nanhai's version has
purgatory/arch/ia64/entry.S!).  Perhaps there might be a better outlet
for that much creativity? [Which is another way of saying that I'm
not interested in seeing a patch to enable the ia32 kexec entry point
on ia64 ... so don't waste any time creating one].

-Tony
