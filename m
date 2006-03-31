From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date: Fri, 31 Mar 2006 17:40:34 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <87irpums19.fsf@duaron.myhome.or.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net> <200603311853.32870.ak@suse.de>
	<87ek0ipmae.fsf@duaron.myhome.or.jp> <200603311918.35207.ak@suse.de>
In-Reply-To: <200603311918.35207.ak@suse.de> (Andi Kleen's message of "Fri, 31 Mar 2006 19:18:34 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Jes Sorensen <jes@sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Andi Kleen <ak@suse.de> writes:

>> 	char stack_pps[POLL_STACK_ALLOC]
>>         	__attribute__((aligned (sizeof(struct poll_list))));
>
> This would require much more alignment than really necessary. Probably you meant
> s/sizeof/alignof/. But Jes' patch is fine I think.

I read your this patch now, so, I agree. Sorry for noise.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
