From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 16 Dec 2004 17:07:43 +0000
Subject: Re: [PATCH] add legacy I/O port & memory APIs to /proc/bus/pci
Message-Id: <200412160907.44091.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412160850.20223.jbarnes@engr.sgi.com> <41C1BA38.60304@osdl.org>
In-Reply-To: <41C1BA38.60304@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, willy@debian.org

On Thursday, December 16, 2004 8:39 am, Randy.Dunlap wrote:
> meta-comment:
> Would you (and not just you :) include a diffstat summary so we
> can see which files are being changed?  something like this:
>
>
>   Documentation/filesystems/proc-pci.txt |  126
> +++++++++++++++++++++++++++++++++
>   arch/ia64/pci/pci.c                    |  105
> +++++++++++++++++++++++++++
>   arch/ia64/sn/pci/pci_dma.c             |   74 +++++++++++++++++++
>   drivers/pci/proc.c                     |  100 +++++++++++++++++++++++---
>   include/asm-ia64/machvec.h             |   24 ++++++
>   include/asm-ia64/machvec_init.h        |    3
>   include/asm-ia64/machvec_sn2.h         |    6 +
>   include/asm-ia64/pci.h                 |    4 +
>   include/asm-ia64/sn/sn_sal.h           |   47 ++++++++++++
>   include/linux/pci.h                    |   12 ++-
>   10 files changed, 488 insertions(+), 13 deletions(-)

Sure, I keep forgetting to do that for the larger patches.  Thanks for 
reminding me.

Jesse
