From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Nov 2003 20:49:53 +0000
Subject: Re: Inefficient TLB flushing
Message-Id: <marc-linux-ia64-106867022429014@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106866775025427@msgid-missing>
In-Reply-To: <marc-linux-ia64-106866775025427@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 Nov 2003 14:01:19 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> Does this analysis look correct??

Yup.

  Jack> Here is the patch that I am currently testing:

  Jack> --- /usr/tmp/TmpDir.19957-0/linux/mm/memory.c_1.79	Wed Nov 12 13:56:25 2003
  Jack> +++ linux/mm/memory.c	Wed Nov 12 12:57:25 2003
  Jack> @@ -574,9 +574,10 @@
  Jack>  			if ((long)zap_bytes > 0)
  Jack>  				continue;
  Jack>  			if (need_resched()) {
  Jack> +				int fullmm = (*tlbp)->fullmm;
  Jack>  				tlb_finish_mmu(*tlbp, tlb_start, start);
  Jack>  				cond_resched_lock(&mm->page_table_lock);
  Jack> -				*tlbp = tlb_gather_mmu(mm, 0);
  Jack> +				*tlbp = tlb_gather_mmu(mm, fullmm);
  Jack>  				tlb_start_valid = 0;
  Jack>  			}
  Jack>  			zap_bytes = ZAP_BLOCK_SIZE;

I think the patch will work fine, but it's not very clean, because it
bypasses the TLB-flush API and directly accesses
implementation-specific internals.  Perhaps it would be better to pass
a "fullmm" flag to unmap_vmas().  Andrew?

	--david
