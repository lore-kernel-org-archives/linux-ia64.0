From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Oct 2002 17:56:17 +0000
Subject: RE: [Linux-ia64] [patch 2.5.39] allow kernel to be virtually mapp
Message-Id: <marc-linux-ia64-105590709805174@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805165@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805165@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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

