From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Oct 2003 21:44:04 +0000
Subject: RE: [PATCH 2.6.0test5: 2 of 3] MCA/TLB recovery
Message-Id: <marc-linux-ia64-106564946702005@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106522368223247@msgid-missing>
In-Reply-To: <marc-linux-ia64-106522368223247@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Tony> +/* Bitmasks of implemented registers */
>   Tony> +static u64 arbits[2] = { 0x11117f2f00ffUL, 0x7UL };
>   Tony> +static u64 crbits[2] = { 0x3fb0107UL, 0x307ffUL };
> 
> Shouldn't these masks be obtained from PAL?

You are right ... PAL_REGISTER_INFO returns this information (I
had forgotten that it existed).

>   Tony> +static u64 brbits[1] = { 0xffUL };
>   Tony> +static u64 rrbits[1] = { 0xffUL };
> 
> These look a bit weird to me (since they're architected), but I guess
> it's your call...

This just fell out of sharing the same code to print the register
values ... it might look less weird if I fix the arbits/crbits code
to use PAL_REGISTER_INFO.

Overall this part of the patch is mostly fluff.  Long term the
right thing to do is remove all these printk()s from the kernel
and leave paring of SAL error records to some user mode code (using
some mechanism like Bjorn did in 2.4).

Any comments on parts 1 & 3???

-Tony
