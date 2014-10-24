From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 24 Oct 2014 12:08:11 +0000
Subject: Re: [PATCH v9 05/12] x86, mpx: on-demand kernel allocation of bounds tables
Message-Id: <alpine.DEB.2.11.1410241257300.5308@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-6-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1413088915-13428-6-git-send-email-qiaowei.ren@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Sun, 12 Oct 2014, Qiaowei Ren wrote:
> +	/*
> +	 * Go poke the address of the new bounds table in to the
> +	 * bounds directory entry out in userspace memory.  Note:
> +	 * we may race with another CPU instantiating the same table.
> +	 * In that case the cmpxchg will see an unexpected
> +	 * 'actual_old_val'.
> +	 */
> +	ret = user_atomic_cmpxchg_inatomic(&actual_old_val, bd_entry,
> +					   expected_old_val, bt_addr);

This is fully preemptible non-atomic context, right?

So this wants a proper comment, why using
user_atomic_cmpxchg_inatomic() is the right thing to do here.

Thanks,

	tglx
