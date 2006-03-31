From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date: Fri, 31 Mar 2006 17:19:12 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <87wteao7lb.fsf@duaron.myhome.or.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net>
	<87irpupo3y.fsf@duaron.myhome.or.jp> <200603311853.32870.ak@suse.de>
	<87ek0ipmae.fsf@duaron.myhome.or.jp>
In-Reply-To: <87ek0ipmae.fsf@duaron.myhome.or.jp> (OGAWA Hirofumi's message of "Sat, 01 Apr 2006 02:16:25 +0900")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Jes Sorensen <jes@sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:

> 	char stack_pps[POLL_STACK_ALLOC]
>         	__attribute__((aligned (sizeof(struct poll_list))));

Ugh, just wrong. Please ignore.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
