From: "Lee, Jung-Ik" <jung-ik.lee@intel.com>
Date: Thu, 17 Oct 2002 01:08:18 +0000
Subject: [Linux-ia64] Some Modules fail w/ unresolved cpu_info__per_cpu
Message-Id: <marc-linux-ia64-105590709805176@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 2.5.39, 
it fails to insmod some modules that refers to "cpu_info__per_cpu".
That global IS DEFINE_PER_CPU'd, DECLARE_PER_CPU'd and is in System.map but
for some reason it fails to resolve.
Have you guys seen this ?

thanks
J.I.

-----Original Message-----
From: Luck, Tony [mailto:tony.luck@intel.com]
Sent: Wednesday, October 16, 2002 10:56 AM
To: Luck, Tony; linux ia64 kernel list
Cc: linux-kernel@vger.kernel.org
Subject: RE: [Linux-ia64] [patch 2.5.39] allow kernel to be virtually
mapp ed from any physi cal address


Yesterday I wrote:
> This patch provides just the code needed to virtually map the
> kernel to a fixed virtual address from whatever physical address
> it happened to be loaded at (it is assumed that the bootloader
> handled the issue of finding a suitably aligned piece of memory).

Elilo already knows how to find memory, as long as you either use
the "relocatable" keyword in elilo.conf, or the "-r" command-line
option to let it know that it is OK to relocate.

Using this elilo option means that the changes I provided for
vmlinux.ld.S can be very slightly simplified, it isn't necessary
to define BASE_KVADDR as "KERNEL_START + KERNEL_TR_PAGE_SIZE", you
can just use:

#define BASE_KVADDR	KERNEL_START

-Tony

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

