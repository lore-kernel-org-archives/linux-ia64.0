From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Jul 2005 20:17:08 +0000
Subject: RE: [PATCH 2.6.13-rc1 07/10] IOCHK interface for I/O error handling/detecting
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03DC33B7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB6961.2060508@jp.fujitsu.com>
In-Reply-To: <42CB6961.2060508@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I don't think this is really safe.  There is nothing to stop the
>compiler from loading the value directly into the out register, which
>would again defer consumption of the value (especially if the caller
>of ia64_mca_barrier() got inlined itself.

I'd thought that the value needs to go to both the "out" register, and
to "r8" to be returned from the function ... but you are right, this
can be by-passed if the function that calls ia64_mca_barrier is itself
inlined.

>In my opinion, it would be safest to write this in assembly, so we're
>_guaranteed_ it will do what we want, no matter how smart the
>compilers get.  Something along the lines of:
>
>ia64_mca_barrier:
>   mov r8 = r32
>   br.ret.sptk.many rp
>
>should do (and I agree that this function needs a comment).

So are you envisioning using it like this?

	val = ia64_mca_barrier(*(type *)ioaddr);

-Tony


