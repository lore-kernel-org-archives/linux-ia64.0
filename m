From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 07 May 2007 01:04:31 +0000
Subject: Re: [patch] Support multiple CPUs going through OS_MCA
Message-Id: <463E7B1F.30906@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704272129.l3RLT8Ob64391823@clink.americas.sgi.com>
In-Reply-To: <200704272129.l3RLT8Ob64391823@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> @@ -1232,6 +1258,7 @@ ia64_mca_handler(struct pt_regs *regs, s
>  		rh->severity = sal_log_severity_corrected;
>  		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
>  		sos->os_status = IA64_MCA_CORRECTED;
> +		ia64_mlogbuf_dump();
>  	} else {
>  		/* Dump buffered message to console */
>  		ia64_mlogbuf_finish(1);

We cannot call ia64_mlogbuf_dump() from recoverable MCA/INIT
context. Since ia64_mlogbuf_dump() calls printk() which could
cause deadlock in MCA/INIT context, this change may be trouble.

Thanks,
H.Seto
