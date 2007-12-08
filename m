From: Roland McGrath <roland@redhat.com>
Date: Sat, 08 Dec 2007 01:17:25 +0000
Subject: Re: [PATCH 3/3] Synchronize RBS on PTRACE_ATTACH
Message-Id: <20071208011725.8F0BC26F8EA@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1196959949.6586.10.camel@elijah.suse.cz>
In-Reply-To: <1196959949.6586.10.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  	if (request = PTRACE_ATTACH) {
>  		ret = ptrace_attach(child);
> +		if (ret = 0)
> +			ptrace_attach_sync_user_rbs(child);
>  		goto out_tsk;

Please make this arch_ptrace_attach(child) and #define it to
ptrace_attach_sync_user_rbs for ia64.  That way it will still be doing the
right thing later on when we clean up ia64 ptrace to get rid of sys_ptrace
and define only arch_ptrace instead.


Thanks,
Roland
