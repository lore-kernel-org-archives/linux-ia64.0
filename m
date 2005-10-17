From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 17 Oct 2005 09:32:17 +0000
Subject: Re: perfmon not counting idle?
Message-Id: <20051017093217.GA2446@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt,

On Tue, Oct 18, 2005 at 03:44:53AM +1000, Matt Chapman wrote:
> I am probably missing something blatantly obvious due to lack of sleep,
> but, I can't seem to get perfmon to include the idle task.
> 
> I booted with nohalt and even commented out pm_idle and safe_halt in the
> idle loop, to try and make sure that power management isn't kicking in,
> but I still get numbers that seem to exclude idle time.
> 
> torrone:~# pfmon --system-wide
> <press ENTER to stop session>
>   ... run for a few seconds ...
> CPU0                       69597 CPU_CYCLES
> 
By default pfmon measures only at the user level (pl3).  If you want
kernel+user you need to add -k. You can tune priv levels per event
using --prev-levels.
