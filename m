From: Keith Owens <kaos@sgi.com>
Date: Mon, 23 Feb 2004 21:38:16 +0000
Subject: Re: [patch] 2.6.3 sync unwind code with 2.4.25
Message-Id: <7283.1077572296@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4545.1077507994@kao2.melbourne.sgi.com>
In-Reply-To: <4545.1077507994@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Feb 2004 12:07:39 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Mon, 23 Feb 2004 14:46:34 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> The unwind code in 2.6.3 is missing a debug patch.  This
>  Keith> patch is in 2.4.25 and makes it much easier to diagnose
>  Keith> unwind problems.  printk output does not appear when
>  Keith> in_interrupt(), kdb_printf output does.  This brings 2.6.3
>  Keith> unwind closer to 2.4.25.
>
>Sorry, but I just don't see why there should be KDB-stuff in unwind.c
>when KDB isn't part of the official Linux tree.

You took the same patch for unwind.c in the 2.4 kernel.

