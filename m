From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 15 Sep 2005 16:46:26 +0000
Subject: Re: [PATCH] Updated /proc/iomem patch
Message-Id: <200509151046.26715.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1126716323.29344.55.camel@lyra.fc.hp.com>
In-Reply-To: <1126716323.29344.55.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 15 September 2005 10:26 am, Khalid Aziz wrote:
> I am not sure if marking the memory allocated by bootloader for kernel,
> inital ramdisk, EFI memory map and boot parameters as "reserved"
> in /proc/iomem is the right thing to do. I have done it this way in the
> patch but I would appreciate other opinions.

I'm curious about how kexec-tools uses the information from iomem.
It tells you about physical address space, and you can't do much
with physical addresses from user-space.  I suppose it's obvious
from the kexec-tools source -- do you have a pointer?
