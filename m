From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Mar 2005 21:09:26 +0000
Subject: RE: cpu_to_node_map on UP systems
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F030ED39A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110350919.9439.16.camel@localhost>
In-Reply-To: <1110350919.9439.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>fyi, I tried a UP build of linux-ia64-test-2.6.12 (assuming I checked
>out the right stuff - I don't use bk much), and I get the following
>compile error:
>
>  AS      arch/ia64/kernel/head.o
>arch/ia64/kernel/head.S:267:54: macro
>"SAL_TO_OS_BOOT_HANDOFF_STATE_SAVE" passed 3 arguments, but 
>takes just 2
>make[1]: *** [arch/ia64/kernel/head.o] Error 1

I'd just found the same thing ... Ashok gave me a patch, and
I just pushed it up to bkbits.  So do a "bk pull" and try again.

-Tony
