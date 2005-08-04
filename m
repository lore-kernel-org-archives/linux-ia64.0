From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 04 Aug 2005 17:55:29 +0000
Subject: RE: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F041310D1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>The kernel I tried was a GENERIC kernel (DIG still works on Tiger).  Also
>tested on HP Eiger, same result: the system gets an MCA.  I've attached
>the config I'm using.

Using that config on my Tiger, I didn't see an MCA, but I did have an
OOPS with a stacktrace that includes:

init
  uncached_init
   efi_memmap_walk_uc
     uncached_build_memmap
       gen_pool_free ...

Sticking in a "return" at the start of efi_memmap_walk_uc() to bypass
this got me a lot further (I died while "Creating root device" ... probably
because my scripts mistakenly thought that MPT was configured in).

So it looks like your problem is CONFIG_IA64_UNCACHED_ALLOCATOR=y

-Tony
