From: Will Deacon <will.deacon@arm.com>
Date: Thu, 24 Aug 2017 09:47:56 +0000
Subject: Re: [PATCH v2 1/1] futex: remove duplicated code and fix UB
Message-Id: <20170824094756.GA6346@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170824073105.3901-1-jslaby@suse.cz>
In-Reply-To: <20170824073105.3901-1-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Slaby <jslaby@suse.cz>
Cc: tglx@linutronix.de, mingo@redhat.com, dvhart@infradead.org, peterz@infradead.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Catalin Marinas <catalin.marinas@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paul>

Hi Jiri,

On Thu, Aug 24, 2017 at 09:31:05AM +0200, Jiri Slaby wrote:
> There is code duplicated over all architecture's headers for
> futex_atomic_op_inuser. Namely op decoding, access_ok check for uaddr,
> and comparison of the result.
> 
> Remove this duplication and leave up to the arches only the needed
> assembly which is now in arch_futex_atomic_op_inuser.
> 
> This effectively distributes the Will Deacon's arm64 fix for undefined
> behaviour reported by UBSAN to all architectures. The fix was done in
> commit 5f16a046f8e1 (arm64: futex: Fix undefined behaviour with
> FUTEX_OP_OPARG_SHIFT usage). Look there for an example dump.
> 
> And as suggested by Thomas, check for negative oparg too, because it was
> also reported to cause undefined behaviour report.
> 
> Note that s390 removed access_ok check in d12a29703 ("s390/uaccess:
> remove pointless access_ok() checks") as access_ok there returns true.
> We introduce it back to the helper for the sake of simplicity (it gets
> optimized away anyway).

For arm64 and the core code:

Reviewed-by: Will Deacon <will.deacon@arm.com>

Although one minor thing on the core part:

> diff --git a/kernel/futex.c b/kernel/futex.c
> index 0939255fc750..3d38eaf05492 100644
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -1551,6 +1551,45 @@ futex_wake(u32 __user *uaddr, unsigned int flags, int nr_wake, u32 bitset)
>  	return ret;
>  }
>  
> +static int futex_atomic_op_inuser(unsigned int encoded_op, u32 __user *uaddr)
> +{
> +	unsigned int op =	  (encoded_op & 0x70000000) >> 28;
> +	unsigned int cmp =	  (encoded_op & 0x0f000000) >> 24;
> +	int oparg = sign_extend32((encoded_op & 0x00fff000) >> 12, 12);
> +	int cmparg = sign_extend32(encoded_op & 0x00000fff, 12);
> +	int oldval, ret;
> +
> +	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28)) {
> +		if (oparg < 0 || oparg > 31)
> +			return -EINVAL;
> +		oparg = 1 << oparg;
> +	}
> +
> +	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
> +		return -EFAULT;
> +
> +	ret = arch_futex_atomic_op_inuser(op, oparg, &oldval, uaddr);
> +	if (ret)
> +		return ret;

We could move the pagefault_{disable,enable} calls here, and then remove
them from the futex_atomic_op_inuser callsites elsewhere in futex.c

Will
