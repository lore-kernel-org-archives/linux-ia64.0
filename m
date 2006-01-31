From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Jan 2006 18:08:57 +0000
Subject: Re: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <20060131180857.GA8442@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270137.k0R1big21236@unix-os.sc.intel.com>
In-Reply-To: <200601270137.k0R1big21236@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 31, 2006 at 11:19:35AM +0000, Christoph Hellwig wrote:
> Agreed.  Obsfucating for a propritary and pretty much irrelevant (for the
> kernel) compiler is a horrible thing to do.  And the only reason we do that
> at all is that the compiler is from the same company that's behind ia64.
> Please fix up your damn compiler.  Even SGI managed to add proper inline
> as?embly support to Pro64, and they had much less ressources.

How about we un-obfuscate the code by moving these three functions to
a ".S" file?  They are reading from uncached physical memory, and are
packed full of "srlz.i" and ".acq"/".rel" options, so it doesn't appear
that moving them from inline to a full procedure call would make any
measurable difference to performance (at least not for any macrobenchmark).

pio_phys_read_mmr() isn't even used anyplace, so we could further clarify
the code by dropping it altogether.

-Tony
