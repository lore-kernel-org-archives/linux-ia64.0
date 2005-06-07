From: Dean Nelson <dcn@sgi.com>
Date: Tue, 07 Jun 2005 15:48:46 +0000
Subject: Re: [PATCH] MAX_USER_RT_PRIO and MAX_RT_PRIO are wrong!
Message-Id: <20050607154846.GA1253@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1118112390.4533.10.camel@localhost.localdomain> <20050607053306.GA16181@elte.hu> <1118143504.4533.21.camel@localhost.localdomain>
In-Reply-To: <1118143504.4533.21.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: mingo@elte.hu, linux-ia64@vger.kernel.org, linux-altix@sgi.com, edwardsg@sgi.com, linux-kernel@vger.kernel.org, akpm@osdl.org, anton.wilson@camotion.com

On Tue, Jun 07, 2005 at 07:25:04AM -0400, Steven Rostedt wrote:
> On Tue, 2005-06-07 at 07:33 +0200, Ingo Molnar wrote:
> > * Steven Rostedt <rostedt@goodmis.org> wrote:
> > 
> > > I tested the patch on an SMP machine where MAX_RT_PRIO = 100 and 
> > > MAX_USER_RT_PRIO = 99. Without the patch, the system crashes with a 
> > > reboot.
> > 
> > Acked-by: Ingo Molnar <mingo@elte.hu>
> 
> If this patch does go in, then xpc_activating in
> arch/ia64/sn/kernel/xpc_main.c (from rc6) also needs to use MAX_RT_PRIO
> instead of MAX_USER_RT_PRIO. Unless it is OK that it runs lower in
> priority than other kernel threads.

You are correct xpc_activating() needs to be changed to use MAX_RT_PRIO.
So please do add that change to your patch.

Thanks,
Dean

