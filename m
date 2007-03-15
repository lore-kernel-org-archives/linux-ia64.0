From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 15 Mar 2007 22:30:47 +0000
Subject: Re: [BUGFIX][PATCH] fixing placement of register stack under ulimit
Message-Id: <20070316073047.8c92bcd1.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070315171743.e85b8405.kamezawa.hiroyu@jp.fujitsu.com>
	<ed5aea430703150857i4c60dbfdrd5c871235815e5da@mail.gmail.com>
	<20070316062047.fbdae1ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070316062047.fbdae1ed.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: dmosberger@gmail.com, linux-ia64@vger.kernel.org, tony.luck@intel.com, linux-kernel@vger.kernel.org

On Fri, 16 Mar 2007 06:20:47 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 15 Mar 2007 09:57:28 -0600
> "David Mosberger-Tang" <dmosberger@gmail.com> wrote:
> 
> > But aren't you going to be limited to less than a page worth of
> > register-backing store even with your patch applied because the
> > backing store will end up overflowing the memory stack?
> > 
> 
> I think pthread's stack, which is created by malloc, is also shared
> among register-stack and memory-stack. 
> (glibc's pthread's stack is limited by ulimit, too.)
> 
> So, it seems stack_size_limit = register_stack_limit + memory_stack_limit
> is a consistent way. I'm sorry if I don't catch your point.
> 
BTW, what way do you recommened to fix this register-stack/memory-stack upside
down problem ?

Plan A) just handle upside-down case in page fault handler.
	This means ulimit -s limitation will limit amount of memory-stack and
	register stack independently.
Plan B) handle upside-down case in page fault handler and add modify 
 	acct_stack_growth() to be able to handle the limitation of sum
	of separated vmas.(vma for reg stack and mem stack). 
Plan C) don't allow this upside down as this patch. but change calculation of rbs_top.

Note:
To see the problem which my patch want to fix run following code under ulimit -s.

=
void eat_stack(int num) {
	printf("%d\n", num);
	eat_stack(num - 1);
}

int main (void) {
	eat_stack(10000);
}
=

-- Kame

