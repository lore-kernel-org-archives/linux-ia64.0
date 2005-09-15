From: Khalid Aziz <khalid_aziz@hp.com>
Date: Thu, 15 Sep 2005 17:27:44 +0000
Subject: Re: [PATCH] Updated /proc/iomem patch
Message-Id: <1126805264.21053.19.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1126716323.29344.55.camel@lyra.fc.hp.com>
In-Reply-To: <1126716323.29344.55.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-09-15 at 10:46 -0600, Bjorn Helgaas wrote:
> On Thursday 15 September 2005 10:26 am, Khalid Aziz wrote:
> > I am not sure if marking the memory allocated by bootloader for kernel,
> > inital ramdisk, EFI memory map and boot parameters as "reserved"
> > in /proc/iomem is the right thing to do. I have done it this way in the
> > patch but I would appreciate other opinions.
> 
> I'm curious about how kexec-tools uses the information from iomem.
> It tells you about physical address space, and you can't do much
> with physical addresses from user-space.  I suppose it's obvious
> from the kexec-tools source -- do you have a pointer?

As kexec tools reads various segments from the kernel image file, it
reads their final memory address where they should be loaded ina nd
attempts to verify if those addresses are valid. This is where it uses
information from /proc/iomem to determine if load addresses are indeed
real memory. This check prevents bad image from being loaded which kexec
will then try to execute later on kexec -e.

You can get kexec-tools sources from
<http://www.xmission.com/~ebiederm/files/kexec/>, or for Debian
unstable, simply "apt-get source kexec-tools" will pull the sources
down.

-- 
Khalid

==================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

