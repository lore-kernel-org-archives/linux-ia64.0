From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Sep 2003 15:05:05 +0000
Subject: Re: 4 SGI patches - non-identity mapped kernel + misc fixes
Message-Id: <marc-linux-ia64-106268822826371@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sunday 31 August 2003 7:31 am, Jack Steiner wrote:
> Attached are 4 patches for the SGI platform. These are against the latest
> 2.4 bitkeeper tree.
> 
> The patches:
> 
> 	linux/arch/ia64/config.in
> 		- delete some remnents of support for the SGI SN1 platform
> 		- add config option for SN2. 
> 
> 	linux_base/arch/ia64/kernel/Makefile
> 		- fix compile error (SN2 needs iosapic.o)
> 
> 	linux/arch/ia64/acpi.c
> 		- update acpi.c to recognize the SN2 platform
> 
> 	linux/arch/ia64/kernel/efi_stub.S
> 	linux/arch/ia64/kernel/head.S
> 	linux/arch/ia64/kernel/pal.S
> 		- backport of 2.6 "ia64_switch_mode" changes for non-identity
> 	  	  mapped kernels

I applied these, thanks.

Bjorn

