From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 08 Dec 2003 23:28:30 +0000
Subject: Re: q-tools OOPS
Message-Id: <marc-linux-ia64-107092660132759@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092374429612@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092374429612@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter,

On Tue, Dec 09, 2003 at 09:46:18AM +1100, Peter Chubb wrote:
> 
> When run on a vanilla 2.6.0-test11 kernel, I either get no output, or
> an OOPS.  stracing q-syscollect always shows a SEGV in the child
> processes, but I think that may be an strace bug.
> I guess that this *could* be a preemption problem; have you run
> q-syscollect on a machine with CONFIG_PREEMPT on?
> 
I don't think that perfmon-2 support CONFIG_PREEMPT. Try without it.

-- 
-Stephane
