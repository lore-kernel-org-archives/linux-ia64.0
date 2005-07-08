From: david mosberger <dmosberger@gmail.com>
Date: Fri, 08 Jul 2005 19:23:54 +0000
Subject: Re: [PATCH 2.6.13-rc1 07/10] IOCHK interface for I/O error handling/detecting
Message-Id: <ed5aea4305070812231e9dcf50@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB6961.2060508@jp.fujitsu.com>
In-Reply-To: <42CB6961.2060508@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 7/8/05, Luck, Tony <tony.luck@intel.com> wrote:
> Cc: list was trimmed because I'm only discussing ia64 issue here.
> 
> >I'm not familiar with assembly code for intel compiler. So David,
> >could you write another macro of ia64_mca_barrier() or a proper
> >subroutine instead?
> 
> Each of the uses of ia64_mca_barrier() is like this ...
> 
>         val = *(... *)addr; /* read from I/O address */
> 
>         ia64_mca_barrier(val); /* consume result */
> 
>         return val;
> 
> Now it appears to me that if you just define ia64_mca_barrier()
> as an empty function (in C):
> 
> void
> ia64_mca_barrier(unsigned long v)
> {
> }
> 
> then this will force a consumption of the value (since the compiler
> will have to copy it from whatever register it was in to an "out"
> register to pass to the function).  Without the call, then the
> compiler will probably allocate "r8" for "val" ... so there will
> be no consumption.

I don't think this is really safe.  There is nothing to stop the
compiler from loading the value directly into the out register, which
would again defer consumption of the value (especially if the caller
of ia64_mca_barrier() got inlined itself.

In my opinion, it would be safest to write this in assembly, so we're
_guaranteed_ it will do what we want, no matter how smart the
compilers get.  Something along the lines of:

ia64_mca_barrier:
   mov r8 = r32
   br.ret.sptk.many rp

should do (and I agree that this function needs a comment).

  --david
