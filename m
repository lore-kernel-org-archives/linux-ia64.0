From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 23 Apr 2007 17:36:00 +0000
Subject: Re: [PATCH] ia64 sn xpc: Convert to use kthread API.
Message-Id: <m1r6qbvvr3.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <m1slawn9eb.fsf@ebiederm.dsl.xmission.com>
	<1176969574439-git-send-email-ebiederm@xmission.com>
	<20070422203647.GC23015@infradead.org> <462CE8D5.8040300@sgi.com>
In-Reply-To: <462CE8D5.8040300@sgi.com> (Jes Sorensen's message of "Mon, 23
	Apr 2007 19:11:49 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, "<Andrew Morton" <akpm@osdl.org>, containers@lists.osdl.org, Oleg Nesterov <oleg@tv-sign.ru>, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, rja@sgi.com, holt@sgi.com, dcn@sgi.com, linux-ia64@vger.kernel.org

Jes Sorensen <jes@sgi.com> writes:

>
> Like with the previous patch from Eric, I'm CC'ing the correct people
> for this patch (forwarded it in a seperate email). CC'ing irrelevant
> lists such as containers@ and not linux-ia64@ makes it somewhat
> difficult to get proper reviews of these things.

containers is actually relevant because everything not being converted
to a kthread API is actually show stopper issue for the development of
the pid namespace because of the usage of pids by kernel_thread, and
the apparent impossibility to fix daemonize to sort this out.

Now I do agree linux-ia64 is also relevant.

> Russ/Dean/Robin - could one of you provide some feedback to this one
> please.

Eric
