From: Paul Mackerras <paulus@samba.org>
Date: Tue, 27 Jan 2004 23:49:10 +0000
Subject: Re: [patch] 2.6.1-mm5 compile do not use shared extable code for
Message-Id: <16406.63734.400759.452955@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1Aiuv7-0001cS-00@jaguar.mkp.net>
	<20040120090004.48995f2a.akpm@osdl.org>
	<16401.57298.175645.749468@napali.hpl.hp.com>
	<16402.19894.686335.695215@cargo.ozlabs.ibm.com>
	<16405.41953.344071.456754@napali.hpl.hp.com>
	<16406.10170.911012.262682@cargo.ozlabs.ibm.com>
	<16406.36741.510353.456578@napali.hpl.hp.com>
In-Reply-To: <16406.36741.510353.456578@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@trained-monkey.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

David Mosberger writes:

>   Paul> Also, I don't think there is enough code there to be worth the
>   Paul> bother of trying to abstract the generic routine so you can
>   Paul> plug in different compare and move-element routines.  The
>   Paul> whole sort routine is only 16 lines of code, after all.  Why
>   Paul> not just have an ia64-specific version of sort_extable?
>   Paul> That's what I thought you would do.
> 
> Because the Alpha needs exactly the same code.

I really don't like the uglification of lib/extable.c.  I think it is
much better to have ~20 lines of code in each of arch/ia64/mm and
arch/alpha/mm than to try to generalize lib/extable.c.  Once you add
all the extra definitions you need for your version, I doubt that the
overall savings would be more than a dozen lines or so.

The point is that with lib/extable.c as it is, you can look at one
page of code, and everything you need to understand that code is
there.  With your change, I have to hunt around to check what the
macros are doing on each arch, and flip backwards and forwards to
check side effects, calling environment etc.  With an ia64-specific
extable.c, you should be able to look at one page of code there and
see that the ia64 version is also correct.

Paul.
