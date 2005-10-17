From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Mon, 17 Oct 2005 17:44:53 +0000
Subject: perfmon not counting idle?
Message-Id: <20051017174453.GA13065@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051017093217.GA2446@frankl.hpl.hp.com>
In-Reply-To: <20051017093217.GA2446@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am probably missing something blatantly obvious due to lack of sleep,
but, I can't seem to get perfmon to include the idle task.

I booted with nohalt and even commented out pm_idle and safe_halt in the
idle loop, to try and make sure that power management isn't kicking in,
but I still get numbers that seem to exclude idle time.

torrone:~# pfmon --system-wide
<press ENTER to stop session>
  ... run for a few seconds ...
CPU0                       69597 CPU_CYCLES

If I look at /proc/perfmon in the meantime, everything looks in order,
and exclude idle is 0:

torrone:~# cat /proc/perfmon
perfmon version           : 2.0
model                     : Itanium 2
fastctxsw                 : No
expert mode               : No
ovfl_mask                 : 0x7fffffffffff
PMU flags                 : 0x1
proc_sessions             : 0
sys_sessions              : 1
sys_use_dbregs            : 0
ptrace_use_dbregs         : 0
format                    : 4d-72-be-c0-06-64-41-43-82-b4-d3-fd-27-24-3c-97 default_format
CPU0  overflow intrs      : 0
CPU0  overflow cycles     : 0
CPU0  overflow min        : 18446744073709551615
CPU0  overflow max        : 0
CPU0  smpl handler calls  : 0
CPU0  smpl handler cycles : 0
CPU0  spurious intrs      : 0
CPU0  replay   intrs      : 0
CPU0  syst_wide           : 1
CPU0  dcr_pp              : 1
CPU0  exclude idle        : 0
CPU0  owner               : 1920
CPU0  context             : e00000407d288000
CPU0  activations         : 0

This is Linux 2.6.12 on a Madison CPU.

Am I doing something wrong?

Matt

