From: Ananth N Mavinakayanahalli <amavin@redhat.com>
Date: Mon, 13 Jun 2005 19:48:15 +0000
Subject: Re: [patch 5/5] [kprobes] Tweak to the function return probe design
Message-Id: <42ADE2FF.5020604@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050613190207.954385000@tuna.jf.intel.com> <20050613190323.672988000@tuna.jf.intel.com>
In-Reply-To: <20050613190323.672988000@tuna.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rusty.lynch@intel.com
Cc: akpm@osdl.org, systemtap@sources.redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Hien Nguyen <hien@us.ibm.com>, Prasanna S Panchamukhi <prasanna@in.ibm.com>, Andi Kleen <ak@suse.de>, linuxppc64-dev@ozlabs.org

rusty.lynch@intel.com wrote:

Hi Rusty,

Thanks for doing this. However...

> +
> +		orig_ret_address = (unsigned long)ri->ret_addr;
> +		recycle_rp_inst(ri);
> +
> +		if (orig_ret_address != (unsigned long) &kretprobe_trampoline)
> +			/*
> +			 * This is the real return address. Any other
> +			 * instances associated with this task are for
> +			 * other calls deeper on the call stack
> +			 */
> +			break;
> +	}
> +
> +	BUG_ON(!orig_ret_address);
> +	regs->nip = orig_ret_address;
> +
> +	unlock_kprobes();
> +	preempt_enable_no_resched();
         ^^^^^^^

We don't need this here - on ppc64, we do a preempt_disable/enable in
kprobe_exceptions_notify() and so this will cause a spurious 
preempt_enable().

Thanks,
Ananth
