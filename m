From: Petr Mladek <pmladek@suse.com>
Date: Thu, 06 Jun 2019 07:59:23 +0000
Subject: Re: [RFC] printk: Introduce per context console loglevel.
Message-Id: <20190606075923.suhcxfu7yprhdp7i@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190528002412.1625-1-dima@arista.com>
 <20190528041500.GB26865@jagdpanzerIV>
 <20190528044619.GA3429@jagdpanzerIV>
 <20190528134227.xyb3622gjwu52q4r@pathway.suse.cz>
 <82605abd-14d9-376a-446c-48475ae305dc@i-love.sakura.ne.jp>
 <c265f674-e293-332b-a037-895025354a69@i-love.sakura.ne.jp>
In-Reply-To: <c265f674-e293-332b-a037-895025354a69@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dmitry Safonov <dima@arista.com>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, x86@kernel.org, linux-ia64@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net

On Sun 2019-06-02 15:13:35, Tetsuo Handa wrote:
> Dmitry Safonov proposed KERN_UNSUPPRESSED loglevel which pretends as if
> ignore_loglevel was specified for per printk() basis, for we can fail to
> apply temporarily manipulated console loglevel because console loglevel
> is evaluated when the message is printed to consoles rather than when
> the message is stored into the buffer [1].
> 
> Temporary manipulation of console loglevel for SysRq is applied to only
> the header line.

We should ask why this this is handled this way.

My understanding is to give user feedback that something is going
to happen when the system is not responsive and sysrq is the last
chance to get some information, sync, and reboot.

Maybe, it is not needed these days when the console loglevel
might be manipulated by sysrq as well.

> At first I though that we also want to apply temporary
> manipulation of console loglevel for SysRq to the body lines, for showing
> only the header line is hardly helpful. But I realized that we should not
> force showing the body lines because some users might be triggering SysRq
>  from /proc and reading via syslog rather than via console output. Users
> who need to read via console output should be able to manipulate console
> loglevel by triggering SysRq from console.

Sounds reasonable.

> Since we currently defer storing of the messages from NMI context and
> recursive context, we would need to explicitly pass KERN_UNSUPPRESSED.
> But Sergey Senozhatsky thinks that it might be fine to automatically
> apply KERN_UNSUPPRESSED to printk() from NMI context and recursive
> context, for messages from these contexts are likely important [2].

I do not agree with this. Nobody cared about printk() deadlocks in NMI
for a long time. The idea was that people just should not print
anything there.

Reality shown that people just printed from this context and we needed
to make printk() safe there.

IMHO, expecting that all messages in NMI context are super important
is a similar mistake.

Also sysrq-l prints all backtraces from NMI context. It is huge
amount of output. People might want just store it into the logbuffer.
It is the same as with sysrq-t mentioned above.

> Then, we could avoid explicitly passing KERN_UNSUPPRESSED, by introducing
> per context console loglevel.
> 
> This patch introduces per CPU console loglevel (for in_nmi(), in_irq() and
> in_serving_softirq()) and per thread console loglevel (for in_task()), and
> replaces temporary manipulation of global console_loglevel with temporary
> manipulation of per context console_loglevel based on an assumption that
> users who are temporarily manipulating global console_loglevel needs to
> apply it to only current context. (Note that triggering SysRq-t from /proc
> runs in in_task() context, and it should not disable preemption because it
> may take long period. Thus, per thread console loglevel is used.)

This is too generic and complicated.

Only the single pr_info() in __handle_sysrq() seems to be called with
interrupts enabled. And it happens only when it is triggered via
/proc/sysrq-trigger. Manipulating the console loglevel is
questionable there.

Using the existing printk_context is good enough.

Also the final output is either LOG_ALWAYS_CON or LOG_NEVER_CON.
The API should not pretend that it supports any loglevel granularity.

If we end up with the two states, the API should consist of three
functions, e.g.

   int set_console_verbose(unsigned long *flags);
   int set_console_quiet(unsigned long *flags);
   restore_console_loglevel(int loglevel, unsigned long flags);

Where the first two functions should return the original loglevel
and irqflags.

Best Regards,
Petr
