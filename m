From: Todd Poynor <tpoynor@mvista.com>
Date: Thu, 18 Mar 2004 22:59:54 +0000
Subject: Re: add lowpower_idle sysctl
Message-Id: <405A29EA.6000400@mvista.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040317170436.430acfbe.akpm@osdl.org>	<200403180318.i2I3IDF03166@unix-os.sc.intel.com>	<20040317192821.1fe90f24.akpm@osdl.org> <Pine.LNX.4.58.0403172237470.28447@montezuma.fsmlabs.com>
In-Reply-To: <Pine.LNX.4.58.0403172237470.28447@montezuma.fsmlabs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zwane Mwaikambo <zwane@linuxpower.ca>
Cc: Andrew Morton <akpm@osdl.org>, Kenneth Chen <kenneth.w.chen@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, CPU Freq ML <cpufreq@www.linux.org.uk>

Zwane Mwaikambo wrote:

>>Set some system-wide integer via a sysctl and let the particular
>>architecture decide how best to implement the currently-selected idle mode?
> 
> I'm wondering whether the setting of these magic numbers can't be done
> using cpufreq infrastructure.

I'd vote for using Patrick Mochel's PM subsystem and use a standard set 
of identifiers that are mapped to a platform-specific idle behavior, in 
much the same way as platform suspend modes are handled today.  For 
example, strings echoed to /sys/power/idle could be an interface.  If 
folks are amenable to this I'd be happy to supply a (generic) patch for it.

-- 
Todd Poynor
MontaVista Software

