From: Dean Nelson <dcn@sgi.com>
Date: Tue, 07 Jun 2005 20:19:49 +0000
Subject: Re: [PATCH] MAX_USER_RT_PRIO and MAX_RT_PRIO are wrong!
Message-Id: <20050607201949.GA11013@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1118112390.4533.10.camel@localhost.localdomain> <20050607053306.GA16181@elte.hu> <1118143504.4533.21.camel@localhost.localdomain> <20050607154846.GA1253@sgi.com> <1118165519.5667.3.camel@localhost.localdomain> <20050607191001.GA8768@sgi.com> <1118172182.4972.4.camel@localhost.localdomain>
In-Reply-To: <1118172182.4972.4.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: mingo@elte.hu, linux-ia64@vger.kernel.org, linux-altix@sgi.com, edwardsg@sgi.com, linux-kernel@vger.kernel.org, akpm@osdl.org, anton.wilson@camotion.com

On Tue, Jun 07, 2005 at 03:23:02PM -0400, Steven Rostedt wrote:
> On Tue, 2005-06-07 at 14:10 -0500, Dean Nelson wrote:
> 
> > I just built and tested a kernel and xp/xpc/xpnet modules with your patch
> > applied. It ran fine. The priorities of the xpc kthreads were correct.
> > 
> > Looks good to me.
> 
> Dean, 
> 
> If you can do me a favor, the way you really want to test this is by
> changing MAX_USER_RT_PRIO to 99 and MAX_RT_PRIO to 
> (MAX_USER_RT_PRIO+1).  This will make sure that the patch is working.
> Your kernel thread should still run at priority 99. 
> 
> Check it with:  ps -eo pid,rtprio,comm
> 
> And grep for your thread name.

Just did as you asked and things seem fine. Ran on an SGI altix.
(The first process shown below shouldn't have a priority of 99,
just the others.)

cranberry5:~ # ps -eo pid,rtprio,comm | grep xpc
13325      - xpc_hb
13327     99 xpc08
13467     99 xpc06
13469     99 xpc06c1
13501     99 xpc06c1
13502     99 xpc06c1
cranberry5:~ #

