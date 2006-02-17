From: Jes Sorensen <jes@sgi.com>
Date: Fri, 17 Feb 2006 17:20:14 +0000
Subject: Re: [patch] option to quite unaligned trap warnings
Message-Id: <43F605CE.8010708@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0hd772nhj.fsf@jaguar.mkp.net>
In-Reply-To: <yq0hd772nhj.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> Jes> Hi, This patch is an attempt to find a good compromise to the
> Jes> somewhat contentious issue of the unaligned usertrap warnings.
> 
> 
>>I haven't seen any negative reactions to this one yet and it's been a
>>week so far. Tony any chance you would apply it to your tree?
> 
> 
> Yes, though I might trim the printk() message back a bit, it seems
> a bit[1] over the top.  How about just:
> 
> Unaligned exception warnings have been disabled
> echo 0 > /proc/sys/kernel/ignore-unaligned-usertrap to re-enable

I kinda added that deliberately to make it a strong point to the users
that they really should consider fixing their apps. If we do a simple
message like that they may not realize the cost of it.

I can live with the simple message, but I think it would be good to
swing the cluebat a bit ;-)

Cheers,
Jes
