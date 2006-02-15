From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 15 Feb 2006 19:58:25 +0000
Subject: RE: missing entries in fsys.S
Message-Id: <200602151958.k1FJwQg09773@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060215143359.GB14787@frankl.hpl.hp.com>
In-Reply-To: <20060215143359.GB14787@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Wednesday, February 15, 2006 11:40 AM
> +	// guard against failures to increase NR_syscalls
> +	.org fsyscall_table + 8*NR_syscalls
> 
> Is this redundant ... with the .space directive I don't think
> that this can ever trip ... can it?

Sadly gnu assembler gives only warning if .space's count argument
is zero or negative.

I agree that this is redundant given that we already check the
size in sys_call_table (entry.S).  So this can be removed.  Tony,
do you want me to send you another patch or you can just massage it?

- Ken

