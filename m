From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Sat, 11 Jan 2020 16:37:26 +0000
Subject: [PING PATCH] ia64: fix syscall_get_error()
Message-Id: <20200111163726.GB22612@altlinux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181203031725.GA11573@altlinux.org>
In-Reply-To: <20181203031725.GA11573@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Elvira Khabirova <lineprinter@altlinux.org>, Eugene Syromyatnikov <esyr@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

PING

On Mon, Dec 03, 2018 at 06:17:25AM +0300, Dmitry V. Levin wrote:
> According to documentation in include/asm-generic/syscall.h,
> syscall_get_error() should return -ERRORCODE if the system call failed.
> 
> This change fixes syscall_get_error() implementation on ia64 to match
> its own syscall_set_return_value(), the documentation, and other
> architectures where syscall_get_error() returns a non-positive value.
> 
> Fixes: cfb361f13c81 ("[IA64] utrace syscall.h support for ia64")
> Cc: stable@vger.kernel.org # v2.6.27+
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> ---
>  arch/ia64/include/asm/syscall.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
> index 1d0b875fec44..4ccf888c083d 100644
> --- a/arch/ia64/include/asm/syscall.h
> +++ b/arch/ia64/include/asm/syscall.h
> @@ -35,7 +35,7 @@ static inline void syscall_rollback(struct task_struct *task,
>  static inline long syscall_get_error(struct task_struct *task,
>  				     struct pt_regs *regs)
>  {
> -	return regs->r10 = -1 ? regs->r8:0;
> +	return regs->r10 = -1 ? -regs->r8 : 0;
>  }
>  
>  static inline long syscall_get_return_value(struct task_struct *task,
> -- 
> ldv

-- 
ldv
