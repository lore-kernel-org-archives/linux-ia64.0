From: Khalid Aziz <khalid_aziz@hp.com>
Date: Wed, 28 Sep 2005 21:31:29 +0000
Subject: RE: [PATCH] Updated /proc/iomem patch
Message-Id: <1127943089.17938.22.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1126716323.29344.55.camel@lyra.fc.hp.com>
In-Reply-To: <1126716323.29344.55.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry Tony. Your email got buried and I just saw it. My comments below.

On Fri, 2005-09-16 at 14:02 -0700, Luck, Tony wrote:
> Just a couple of quibbles:
> 
> You still tested for md->num_pages = 0 with a comment saying
> that this may be the result of trimming.  With the clean-up
> to efi_memmap_walk() we don't trim any more, so perhaps this
> whole test can go?  I've kept it with a toned down comment
> (as paranoia against an implementation of EFI that hands us
> a zero sized object).

This was just a paranoidal check.

> 
> What do you need from the "Kernel data" information?  Right
> now you use _edata as the end point ... which is the end of
> initialized data from the kernel Elf file.  But perhaps it
> might be more sane to include all the other sections that
> follow ... and use "_end" as the endpoint (actually _end
> rounded up to a page boundary) ... which neatly fill in the
> block of "System RAM" that the kernel is a sub-resource of
> without leaving some nebulous hole at the end.  I haven't
> changed this yet ... pending your reply on what is needed.
> 

Using _end as endpoint sounds reasonable. Feel free to change it if you
have not done so already.

> And some minor nits (all of which I've fixed)
> 
> use kcalloc() rather than kmalloc+memset
> 
> delay calling the allocator until you know you need it
> 
> register_memory() throws a warning from the __initcall,
> it needs to be an "int" returning function, not "void".
> 
> stylistically I don't like "continue; break;"
> 
> s/printk("ERROR/printk(KERN_ERR "/
> 
> trailing white space deleted
> 
> -Tony
> 

-- 
Khalid

==================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

