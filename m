From: Patrick Mochel <mochel@osdl.org>
Date: Sat, 09 Aug 2003 01:31:07 +0000
Subject: Re: [patch] move efivars to drivers/efi
Message-Id: <marc-linux-ia64-106039247003678@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> This patch against 2.6.0-test2 does several things:
> 
> 1.  Creates a new directory (drivers/efi) into which I propose current and future drivers that interact with EFI firmware be placed.  This enables architectures that employ EFI compliant firmware to use the same drivers and avoid the maintenance hassle of multiple copies.  
> 
> 2.  Move the current EFI variable services driver (efivars) found in arch/ia64/kernel into drivers/efi.
> 
> Note that I've added similar config options for x86 in a separate patch that also enables EFI awareness that I'll resend to the list shortly.  
> 
> Thoughts?  Comments?

Yes - have you considered doing a sysfs interface instead of procfs? :) 


	-pat

