From: Robin Holt <holt@sgi.com>
Date: Tue, 20 Dec 2005 02:35:37 +0000
Subject: Re: Can somebody with flex/bison experience help with genksyms?
Message-Id: <20051220023537.GA27004@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219214019.GA25888@lnx-holt.americas.sgi.com> <jelkygljkg.fsf@sykes.suse.de>
In-Reply-To: <jelkygljkg.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Schwab <schwab@suse.de>
Cc: Robin Holt <holt@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, rth@redhat.com, bj0rn@blox.se

On Tue, Dec 20, 2005 at 01:05:03AM +0100, Andreas Schwab wrote:
> -	| TYPEOF_KEYW '(' decl_specifier_seq ')'
> +	| TYPEOF_KEYW '(' decl_specifier_seq m_abstract_declarator ')'

Thank you.  It was on the STRUCT_KEYW a few lines down and now it
works.  I will post shortly.

Thanks,
Robin
