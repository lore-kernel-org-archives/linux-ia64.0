From: Jes Sorensen <jes@sgi.com>
Date: Mon, 23 Apr 2007 17:11:49 +0000
Subject: Re: [PATCH] ia64 sn xpc: Convert to use kthread API.
Message-Id: <462CE8D5.8040300@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <m1slawn9eb.fsf@ebiederm.dsl.xmission.com> <1176969574439-git-send-email-ebiederm@xmission.com> <20070422203647.GC23015@infradead.org>
In-Reply-To: <20070422203647.GC23015@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, "<Andrew Morton" <akpm@osdl.org>, containers@lists.osdl.org, Oleg Nesterov <oleg@tv-sign.ru>, linux-kernel@vger.kernel.org, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, rja@sgi.com, holt@sgi.com, dcn@sgi.com, linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> On Thu, Apr 19, 2007 at 01:58:44AM -0600, Eric W. Biederman wrote:
>> From: Eric W. Biederman <ebiederm@xmission.com>
>>
>> This patch starts the xpc kernel threads using kthread_run
>> not a combination of kernel_thread and daemonize.  Resuling
>> in slightly simpler and more maintainable code.
> 
> This driver is a really twisted maze.  It has a lot of threads,
> some of them running through the whole lifetime of the driver,
> some short-lived and some in a sort of a pool.
> 
> The patch below fixes up the long-lived thread as well as fixing
> gazillions of leaks in the init routine by switching to proper
> goto-based unwinding.
> 
> Note that thread pools are something we have in a few places,
> and might be worth handling in the core kthread infrastructure,
> as tearing down pools will get a bit complicated using the
> kthread APIs.

Like with the previous patch from Eric, I'm CC'ing the correct people
for this patch (forwarded it in a seperate email). CC'ing irrelevant
lists such as containers@ and not linux-ia64@ makes it somewhat
difficult to get proper reviews of these things.

Russ/Dean/Robin - could one of you provide some feedback to this one
please.

Thanks,
Jes
