From: Andrew Morton <akpm@osdl.org>
Date: Fri, 06 Feb 2004 16:30:50 +0000
Subject: Re: gcc problems
Message-Id: <20040206083050.4e6e1a6b.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab <schwab@suse.de> wrote:
>
> The fields were named differently in old versions of glibc, but the whole
>  layout didn't change in any way.
> 
>  -  unsigned long int sc_rsvd[16];/* reserved for future use */
>  +  unsigned long int sc_rbs_base;/* NULL or new base of sighandler's rbs */
>  +  unsigned long int sc_loadrs;	/* see description above */
>  +  unsigned long int sc_ar25;	/* cmp8xchg16 uses this */
>  +  unsigned long int sc_ar26;	/* rsvd for scratch use */
>  +  unsigned long int sc_rsvd[12];/* reserved for future use */
> 
>  > The easiest workaround is probably to install libunwind on your system
> 
>  The right fix is not to use a 2 years old glibc.

That's not very old.  One shouldn't have to upgrade libc just to build gcc?

