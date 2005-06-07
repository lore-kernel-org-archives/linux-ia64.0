From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 07 Jun 2005 19:23:02 +0000
Subject: Re: [PATCH] MAX_USER_RT_PRIO and MAX_RT_PRIO are wrong!
Message-Id: <1118172182.4972.4.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1118112390.4533.10.camel@localhost.localdomain>
	 <20050607053306.GA16181@elte.hu>
	 <1118143504.4533.21.camel@localhost.localdomain>
	 <20050607154846.GA1253@sgi.com>
	 <1118165519.5667.3.camel@localhost.localdomain>
	 <20050607191001.GA8768@sgi.com>
In-Reply-To: <20050607191001.GA8768@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: mingo@elte.hu, linux-ia64@vger.kernel.org, linux-altix@sgi.com, edwardsg@sgi.com, linux-kernel@vger.kernel.org, akpm@osdl.org, anton.wilson@camotion.com

On Tue, 2005-06-07 at 14:10 -0500, Dean Nelson wrote:

> I just built and tested a kernel and xp/xpc/xpnet modules with your patch
> applied. It ran fine. The priorities of the xpc kthreads were correct.
> 
> Looks good to me.

Dean, 

If you can do me a favor, the way you really want to test this is by
changing MAX_USER_RT_PRIO to 99 and MAX_RT_PRIO to 
(MAX_USER_RT_PRIO+1).  This will make sure that the patch is working.
Your kernel thread should still run at priority 99. 

Check it with:  ps -eo pid,rtprio,comm

And grep for your thread name.

Thanks,

-- Steve


