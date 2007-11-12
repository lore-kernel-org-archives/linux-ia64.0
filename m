From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 12 Nov 2007 16:11:27 +0000
Subject: RE: [PATCH] ptrace RSE bug
Message-Id: <1194883887.22192.12.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2007-11-12 at 16:41 +0100, Petr Tesarik wrote:
> On Sun, 2007-11-11 at 18:14 -0800, Roland McGrath wrote: 
>[...]
> Hi Roland,
> 
> the trouble is I used the current ia64 patch and even inserted an
> msleep(10) into ptrace_stop() to make sure it does sleep but I don't see
> any problems. I added the following code between arch_ptrace_stop(1) and
> set_current_state(TASK_TRACED):
> 
> 	msleep(10);
> 	if (unlikely(sigismember(&current->pending.signal, SIGKILL)))
> 		printk(KERN_INFO "%d (%s): Got SIGKILL in ptrace_stop\n",
> 			current->pid, current->comm);
> 
> I ran strace on a simple program (calling gettimeofday() in an endless
> loop) and killed it with SIGKILL. The program exited correctly and I got
> the message in syslog. I'm puzzled. :/  Is this not the correct place
> where the race condition should happen?

Ah, Roland, you're right, strace ends with:

+++ killed by SIGKILL +++
Process 2946 detached

I've just realized that it's exactly what SHOULDN'T happen. Sorry for
the fuss.

Regards,
Petr Tesarik

