From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 06 Jun 2005 05:05:54 +0000
Subject: RE: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03A1725C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>There is a linker restriction that you must initialise variables that
>are to be stored in different sections, which is what __initdata does.
>without initialization shub_1_1_found ends up in .bss, with
>initialization it ends up in .init.data.

Keith,

Thanks for the explanation.

At least things will still work as expected, we just won't free up the
memory for uninitialized __initdata objects, which is better than having
__initdata objects initialized to random values.

But it does mean that the docs are right, and that we should fix up
other places where __initdata objects do not have initializers.

-Tony
