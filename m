From: Khalid Aziz <khalid_aziz@hp.com>
Date: Wed, 26 Oct 2005 21:49:18 +0000
Subject: RE: [PATCH] kexec on ia64
Message-Id: <1130363358.25351.12.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-10-26 at 12:02 -0700, Luck, Tony wrote:
> > Cool.  Tony, what are your plans for pushing this to Linus?  Will it make 
> > 2.6.15?
> 
> Nanhai Zou here at Intel expressed a few concerns to me last night
> about Khalid's patch.  I'll paste them here to speed discussion about
> this (as I expect Nanhai is asleep at the moment, he should be
> around to start commenting for himself by 4-5pm Pacific).
> 
> > I think his patch is still not able to boot an unmodified kernel.
> > It appends a kernel parameter to bypass the issue, thus the second kernel need to be modified.
> 

True. The only time I use this parameter is to determine whether to
virtualize EFI or not. EFI does not respond well to being virtualized
once it has been virtualized already. So the kernel needs to know if EFI
has already been virtualized by previous kernel. It is possible to pass
this information to the next kernel as a command line parameter, as I
have done, or in one of the kexec segments. One way or the other, kernel
needs to know this. I have not found a way around it. If there is one, I
would like to hear about it. That will make enable unmodified kernel to
be booted.

> > It also hardcoded initrd logic in kernel patch.

I could not find a better way to pass initrd image to ia64 kernel since
it is not placed in a fixed location. Using a fixed kexec segment looked
fairly logical to me. Alternative would be to add a type field to struct
kexec_segment, then kernel can determine which segment holds initrd
image without having to use a fixed kexec segment.

> > Command line is still using old command line.

Please explain.

> > No purgatory code support etc.
> 
> > How, I prefer to put a small and clean patch in kernel while leave most of the things in kexec-tools. 
> > That will provide more flexibility.
> 
> > There are also some other issues I can see, like, 
> > 1. icache flusing miss
> > 2. rendez code is fake, I prefer to use hotplug API.

That would be preferable, and would be a good enhancement over current
code if it can be made to work reliably. I was planning to look into it
after initial implementation (I wrote initial implementation before CPU
hotplug API was available).

> > 3. Disable PCI master code should be in generic PCI driver code instead of IA64 arch code.

Agreed. This is part of some of the cleanup that can still be done.

> 
> Nanhai has his own patches for kexec/kexec-tools, which are
> stuck in some Intel bureaucracy at the moment ...  I'm trying
> to get them unstuck so that we can get some meaningful
> commentary from the community about both versions.
> 
> My biggest issue with both patches at the moment is that I
> can't see how either of them can be extended to be useful
> for use in crash-dump case without some significant surgery.
> Both of them over-write the existing kernel with the new one,
> which is a big problem when you'd like to dump the data space
> of the old kernel.  Ia64 is quite happy to run a kernel loaded
> at any suitably aligned address ... so why not load the new
> kernel in some different location from the old kernel?
> 
> Including this in 2.6.15?  It's possible, but it's looking like
> this might be a rush.  Assuming Linus releases 2.6.14 by the
> end of this week, we only have a couple of weeks to check that
> this runs on all of the weird configurations.  I'd need to see
> a lot of "tested on xxx-config ... no problems" e-mail to get
> confidence in this.
> 
> -Tony

-- 
Khalid

==================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

