From: Andrew Morton <akpm@osdl.org>
Date: Fri, 04 Feb 2005 11:39:44 +0000
Subject: Re: ia64 uaccess changes?
Message-Id: <20050204033944.64bd70f3.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107509583.2555.51.camel@linux-znh>
In-Reply-To: <1107509583.2555.51.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bob Picco <bob.picco@hp.com> wrote:
>
> Well I was seeing the same problem with 2.6.11-rc2-mm1-mhp1.  
>  This fixed it for me.  I thought a patch had been sent upstream to Tony.
>  I'm not proposing this as a patch.  I believe it was already done.
> 
>  bob
> 
> 
>  diff -ruNp -X /home/picco/losl/dontdiff linux-2.6.11-rc2-mm1-mhp1-orig/arch/ia64/kernel/entry.S linux-2.6.11-rc2-mm1-mhp1/arch/ia64/kernel/entry.S
>  --- linux-2.6.11-rc2-mm1-mhp1-orig/arch/ia64/kernel/entry.S	2005-01-26 15:29:06.000000000 -0500
>  +++ linux-2.6.11-rc2-mm1-mhp1/arch/ia64/kernel/entry.S	2005-01-27 14:30:41.000000000 -0500
>  @@ -987,7 +987,7 @@ dont_preserve_current_frame:
>   	shladd in0=loc1,3,r17
>   	mov in1=0
>   	;;
>  -	.align 32
>  +	TEXT_ALIGN(32)
>   rse_clear_invalid:
>   #ifdef CONFIG_ITANIUM
>   	// cycle 0

That's already in Linus's tree.  And mine.  So it's something else.

Were you seeing the same oops?
