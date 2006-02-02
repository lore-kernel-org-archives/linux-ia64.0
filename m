From: Jes Sorensen <jes@trained-monkey.org>
Date: Thu, 02 Feb 2006 09:39:23 +0000
Subject: Re: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <yq064nyp0ac.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270137.k0R1big21236@unix-os.sc.intel.com>
In-Reply-To: <200601270137.k0R1big21236@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

Tony> On Tue, Jan 31, 2006 at 11:19:35AM +0000, Christoph Hellwig
Tony> wrote:
>> Agreed.  Obsfucating for a propritary and pretty much irrelevant
>> (for the kernel) compiler is a horrible thing to do.  And the only
>> reason we do that at all is that the compiler is from the same
>> company that's behind ia64.  Please fix up your damn compiler.
>> Even SGI managed to add proper inline as?embly support to Pro64,
>> and they had much less ressources.

Tony> How about we un-obfuscate the code by moving these three
Tony> functions to a ".S" file?  They are reading from uncached
Tony> physical memory, and are packed full of "srlz.i" and
Tony> ".acq"/".rel" options, so it doesn't appear that moving them
Tony> from inline to a full procedure call would make any measurable
Tony> difference to performance (at least not for any macrobenchmark).

Tony,

We could do this in this particular case, but it doesn't solve the
fundamental problem. What we really need is Intel showing that it will
fix it's broken compilers once and for all if Intel wishes to continue
compiling the kernel with it.

The way it is right now, it means users who make the mistake of
compiling with ICC ends up exercising different codepaths than what
everybody else runs. This makes bug reports and benchmark results
meaningless.

What I don't understand is why this is so much more difficult for
Intel's compiler team to fix when several other, and much smaller,
teams haven't found it a problem to resolve it in the past.

Tony> pio_phys_read_mmr() isn't even used anyplace, so we could
Tony> further clarify the code by dropping it altogether.

I don't know if there's code in the pipeline which expects to use
this function. Anyone knows?

Again, this is my personal oppinion on this subject, it may differ
from that of my employer.

Regards,
Jes
