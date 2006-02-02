From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Feb 2006 18:54:28 +0000
Subject: RE: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05990CBF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270137.k0R1big21236@unix-os.sc.intel.com>
In-Reply-To: <200601270137.k0R1big21236@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We could do this in this particular case, but it doesn't solve the
> fundamental problem. What we really need is Intel showing that it will
> fix it's broken compilers once and for all if Intel wishes to continue
> compiling the kernel with it.

This one is your call ... you are the official maintainer of this
file now[1].  I think that moving these to a ".S" file represents a
real cleanup (that just happens to help compiling with icc).

> The way it is right now, it means users who make the mistake of
> compiling with ICC ends up exercising different codepaths than what
> everybody else runs. This makes bug reports and benchmark results
> meaningless.

I think that there are some real benefits to building with a different
compiler.  icc has exposed some real bugs in the kernel in the past,
and I expect that it will do so again.

> What I don't understand is why this is so much more difficult for
> Intel's compiler team to fix when several other, and much smaller,
> teams haven't found it a problem to resolve it in the past.

Me too.  On the x86 side icc accepts inline asm(), and there have
been substantial improvements to icc to make it accept many of the
commonly used gcc extensions ... but the ia64 team have steadfastly
stuck to their position that intrinsics are the wave of the future.
As far as the kernel goes this has really slowed down acceptance (and
even use) of icc.  Kernel code contains few constructs where icc can
really shine over gcc, and in any case the C code is often written
with an eye on the instructions that are generated, which further
limits the possible upside.

> Again, this is my personal oppinion on this subject, it may differ
> from that of my employer.

I suspect that some of what I've written above may diverge
from my employer's views too.

-Tony

[1] http://tinyurl.com/7cqz8
