From: Dean Nelson <dcn@sgi.com>
Date: Tue, 07 Jun 2005 19:10:01 +0000
Subject: Re: [PATCH] MAX_USER_RT_PRIO and MAX_RT_PRIO are wrong!
Message-Id: <20050607191001.GA8768@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1118112390.4533.10.camel@localhost.localdomain> <20050607053306.GA16181@elte.hu> <1118143504.4533.21.camel@localhost.localdomain> <20050607154846.GA1253@sgi.com> <1118165519.5667.3.camel@localhost.localdomain>
In-Reply-To: <1118165519.5667.3.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: mingo@elte.hu, linux-ia64@vger.kernel.org, linux-altix@sgi.com, edwardsg@sgi.com, linux-kernel@vger.kernel.org, akpm@osdl.org, anton.wilson@camotion.com

On Tue, Jun 07, 2005 at 01:31:59PM -0400, Steven Rostedt wrote:
> On Tue, 2005-06-07 at 10:48 -0500, Dean Nelson wrote:
> > You are correct xpc_activating() needs to be changed to use MAX_RT_PRIO.
> > So please do add that change to your patch.
> 
> I haven't tested this patch, I just used the previous patch (which I did
> test) and added your change.

I just built and tested a kernel and xp/xpc/xpnet modules with your patch
applied. It ran fine. The priorities of the xpc kthreads were correct.

Looks good to me.

Thanks,
Dean

