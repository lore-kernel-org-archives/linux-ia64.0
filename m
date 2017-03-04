From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Sat, 04 Mar 2017 13:05:50 +0000
Subject: Re: [PATCH 1/3] futex: remove duplicated code
Message-Id: <20170304130550.GT21222@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170303122712.13353-1-jslaby@suse.cz>
In-Reply-To: <20170303122712.13353-1-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Slaby <jslaby@suse.cz>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On Fri, Mar 03, 2017 at 01:27:10PM +0100, Jiri Slaby wrote:
> diff --git a/arch/arm/include/asm/futex.h b/arch/arm/include/asm/futex.h
> index 6795368ad023..cc414382dab4 100644
> --- a/arch/arm/include/asm/futex.h
> +++ b/arch/arm/include/asm/futex.h
> @@ -128,20 +128,10 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
>  #endif /* !SMP */
>  
>  static inline int
> -futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
> +arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
>  {
> -	int op = (encoded_op >> 28) & 7;
> -	int cmp = (encoded_op >> 24) & 15;
> -	int oparg = (encoded_op << 8) >> 20;
> -	int cmparg = (encoded_op << 20) >> 20;
>  	int oldval = 0, ret, tmp;
>  
> -	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
> -		oparg = 1 << oparg;
> -
> -	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
> -		return -EFAULT;
> -
>  #ifndef CONFIG_SMP
>  	preempt_disable();
>  #endif
> @@ -172,17 +162,9 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
>  	preempt_enable();
>  #endif
>  
> -	if (!ret) {
> -		switch (cmp) {
> -		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
> -		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
> -		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
> -		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
> -		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
> -		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
> -		default: ret = -ENOSYS;
> -		}
> -	}
> +	if (!ret)
> +		*oval = oldval;
> +
>  	return ret;
>  }
>  
> diff --git a/kernel/futex.c b/kernel/futex.c
> index b687cb22301c..c5ff9850952f 100644
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -1457,6 +1457,42 @@ futex_wake(u32 __user *uaddr, unsigned int flags, int nr_wake, u32 bitset)
>  	return ret;
>  }
>  
> +static int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
> +{
> +	int op = (encoded_op >> 28) & 7;
> +	int cmp = (encoded_op >> 24) & 15;
> +	int oparg = (encoded_op << 8) >> 20;
> +	int cmparg = (encoded_op << 20) >> 20;

Hmm.  oparg and cmparg look like they're doing these shifts to get sign
extension of the 12-bit values by assuming that "int" is 32-bit -
probably worth a comment, or for safety, they should be "s32" so it's
not dependent on the bit-width of "int".

> +	int oldval, ret;
> +
> +	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
> +		oparg = 1 << oparg;

I guess it doesn't matter that oparg can be >= the bit size of oparg
(so large values produce an undefined result) as it's no different
from userspace trying to do the same with large shifts.

> +
> +	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
> +		return -EFAULT;
> +
> +	ret = arch_futex_atomic_op_inuser(op, oparg, &oldval, uaddr);
> +	if (ret)
> +		return ret;
> +
> +	switch (cmp) {
> +	case FUTEX_OP_CMP_EQ:
> +		return oldval = cmparg;
> +	case FUTEX_OP_CMP_NE:
> +		return oldval != cmparg;
> +	case FUTEX_OP_CMP_LT:
> +		return oldval < cmparg;
> +	case FUTEX_OP_CMP_GE:
> +		return oldval >= cmparg;
> +	case FUTEX_OP_CMP_LE:
> +		return oldval <= cmparg;
> +	case FUTEX_OP_CMP_GT:
> +		return oldval > cmparg;
> +	default:
> +		return -ENOSYS;
> +	}
> +}
> +
>  /*
>   * Wake up all waiters hashed on the physical page that is mapped
>   * to this virtual address:

As it's no worse than our existing code, for the above,

Acked-by: Russell King <rmk+kernel@armlinux.org.uk>

Thanks.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
