From: Adrian Bunk <bunk@kernel.org>
Date: Thu, 07 Aug 2008 14:33:04 +0000
Subject: Re: [IA64] defconfig build failure in current linus.git
Message-Id: <20080807143303.GA9692@cs181140183.pp.htv.fi>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080807101015.GB4342@8bytes.org>
In-Reply-To: <20080807101015.GB4342@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 07, 2008 at 12:10:15PM +0200, Joerg Roedel wrote:
> Hi,
> 
> I just tried to build the current linus.git kernel for IA64 and got the
> following build errors:
> 
>   CC      drivers/acpi/utils.o
> In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:54,
>                  from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
>                  from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
> /data2/repos/tip/linux.trees.git/include/acpi/platform/acenv.h:175:1: warning: "COMPILER_DEPENDENT_INT64" redefined
>...

If you get this error your compiler does not define __linux__ .

What compiler are you using?

> Regards,
> 
> Joerg

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

