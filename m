From: "David S. Miller" <davem@redhat.com>
Date: Thu, 13 Nov 2003 03:56:01 +0000
Subject: Re: Inefficient TLB flushing
Message-Id: <marc-linux-ia64-106869606922555@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106866775025427@msgid-missing>
In-Reply-To: <marc-linux-ia64-106866775025427@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 12 Nov 2003 14:01:19 -0600
Jack Steiner <steiner@sgi.com> wrote:

> --- /usr/tmp/TmpDir.19957-0/linux/mm/memory.c_1.79	Wed Nov 12 13:56:25 2003
> +++ linux/mm/memory.c	Wed Nov 12 12:57:25 2003
> @@ -574,9 +574,10 @@
>  			if ((long)zap_bytes > 0)
>  				continue;
>  			if (need_resched()) {
> +				int fullmm = (*tlbp)->fullmm;
>  				tlb_finish_mmu(*tlbp, tlb_start, start);
>  				cond_resched_lock(&mm->page_table_lock);
> -				*tlbp = tlb_gather_mmu(mm, 0);
> +				*tlbp = tlb_gather_mmu(mm, fullmm);
>  				tlb_start_valid = 0;
>  			}
>  			zap_bytes = ZAP_BLOCK_SIZE;

This patch looks perfectly fine, good analysis.
