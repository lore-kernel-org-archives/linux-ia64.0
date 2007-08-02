From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Aug 2007 16:25:58 +0000
Subject: RE: scripts/mod/file2alias.c cross compile problem
Message-Id: <617E1C2C70743745A92448908E030B2A0211AFF0@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186067359.18821.553.camel@queen.suse.de>
In-Reply-To: <1186067359.18821.553.camel@queen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: trenn@suse.de, Adrian Bunk <bunk@stusta.de>
Cc: Sam Ravnborg <sam@ravnborg.org>, Jan Dittmer <jdi@l4x.org>, Len Brown <lenb@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> Adrian Bunk: scripts/mod/file2alias.c is compiled with HOSTCC and ensures that
> kernel_ulong_t is correct, but it can't cope with different padding on
> different architectures.

Surely this is the root cause ... you can't expect that the alignment
rules of HOSTCC to make any sense for an arbitraty target.

> +#define FILLUP_LEN	7 /* dirty fix for i386 -> 64bit cross-compilation */
>  
>  struct acpi_device_id {
>  	__u8 id[ACPI_ID_LEN];
> +	__u8 dummy[FILLUP_LEN];
>  	kernel_ulong_t driver_data;
>  };

What's so special about this structure that we get an error?  Surely
there are many kernel structures with different alignment/padding
when built with i386 complier compared with ia64 compiler.  We can't
go around manually padding them all (it wastes time, and also wastes
memory on the 32-bit systems that don't need this padding).

-Tony
 
