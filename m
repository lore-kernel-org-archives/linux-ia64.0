From: Andi Kleen <ak@suse.de>
Date: Fri, 31 Mar 2006 17:18:34 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <200603311918.35207.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net> <200603311853.32870.ak@suse.de> <87ek0ipmae.fsf@duaron.myhome.or.jp>
In-Reply-To: <87ek0ipmae.fsf@duaron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Jes Sorensen <jes@sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Friday 31 March 2006 19:16, OGAWA Hirofumi wrote:

> 
> OK. So how about this?
> 
> 	char stack_pps[POLL_STACK_ALLOC]
>         	__attribute__((aligned (sizeof(struct poll_list))));

This would require much more alignment than really necessary. Probably you meant
s/sizeof/alignof/. But Jes' patch is fine I think.

-Andi
