From: Khalid Aziz <khalid_aziz@hp.com>
Date: Mon, 15 Nov 2004 20:41:09 +0000
Subject: Re: [Fastboot] [PATCH] kexec on ia64
Message-Id: <1100551268.26287.35.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-11-15 at 13:32, Khalid Aziz wrote:
> Here is what I am working on next:
> 
> 1. Save EFI memory map before it is trimmed.
> 
> 2. Fix up /proc/iomem on ia64 so we can enable validating memory range
> in kexec tools.
> 
> 3. Add a /proc interface to enable reboots on panic and INIT (and
> possibly MCA) to be kexec reboots.
> 
> 4. Add initrd support.

And

5. Port the patch to 2.6.9 kernel :) Or 2.6.10 if I do not get to it
soon enough.

-- 
Khalid

==================================
Khalid Aziz                                Linux and Open Source Lab
(970)898-9214                                        Hewlett-Packard
khalid_aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
				- Alessandro Rubini


