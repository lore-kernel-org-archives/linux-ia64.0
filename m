From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 23 Mar 2004 02:00:14 +0000
Subject: Re: hardware random number generator?
Message-Id: <405F9A2E.8040509@pobox.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:
> config HW_RANDOM
>         tristate "Intel/AMD/VIA HW Random Number Generator support"
>         depends on (X86 || IA64) && PCI
>         ---help---
>           This driver provides kernel-side support for the Random Number
>           Generator hardware found on Intel i8xx-based motherboards,
>           AMD 76x-based motherboards, and Via Nehemiah CPUs.
> 
> Why IA64 too?  This file contains the code:

No idea.  <guessing>  There are some Intel ICH-based motherboards w/ 
IA64 chips on them, maybe?  I certainly don't recall adding that IA64 
marker... :)

	Jeff




