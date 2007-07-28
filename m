From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 28 Jul 2007 01:39:51 +0000
Subject: scripts/mod/file2alias.c cross compile problem
Message-Id: <20070728013950.GE15129@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727230741.GD15129@stusta.de> <617E1C2C70743745A92448908E030B2A0209BB9D@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0209BB9D@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>
Cc: Thomas Renninger <trenn@suse.de>, Jan Dittmer <jdi@l4x.org>, Len Brown <lenb@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, Jul 27, 2007 at 04:21:47PM -0700, Luck, Tony wrote:
> > So it seems on ia64 with gcc 3.3.6 there's some 8 byte alignment of the 
> > array members?
> >
> > Sam and the ia64 maintainers Cc'ed - they might know better what's going 
> > on here.
> 
> This ia64 maintainer is baffled ... but I don't see the problem here (perhaps
> because my build machine has gcc 3.4.6).


I found what causes this problem, and it only occurs during cross 
compilation.


The struct is:

#define ACPI_ID_LEN     9

struct acpi_device_id {
	 __u8 id[ACPI_ID_LEN];
	kernel_ulong_t driver_data;
};


When compiling for ia64, this results in:

struct acpi_device_id {
	__u8 id[9];
	uint64_t driver_data;
};


sizeof(struct acpi_device_id) for ia64 is due to different padding
after id[] 20 bytes on i386 but 24 bytes on ia64.

scripts/mod/file2alias.c is compiled with HOSTCC and ensures that 
kernel_ulong_t is correct (in this case uint64_t for ia64), but it can't 
cope with different padding on different architectures.


> -Tony

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

