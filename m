From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 04 Aug 2005 18:23:00 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <yq0psstftob.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

Tony> Using that config on my Tiger, I didn't see an MCA, but I did
Tony> have an OOPS with a stacktrace that includes:

Tony> init uncached_init efi_memmap_walk_uc uncached_build_memmap
Tony> gen_pool_free ...

Tony> Sticking in a "return" at the start of efi_memmap_walk_uc() to
Tony> bypass this got me a lot further (I died while "Creating root
Tony> device" ... probably because my scripts mistakenly thought that
Tony> MPT was configured in).

Tony> So it looks like your problem is
Tony> CONFIG_IA64_UNCACHED_ALLOCATOR=y

Impossible, thats my code! It can't be broken ;-)

Anyone who have tried this on an ZX1 box? Otherwise I'll try it out on
my 2600 tomorrow and see if I can reproduce it.

Cheers,
Jes
