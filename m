From: Andrew Morton <akpm@osdl.org>
Date: Fri, 19 Mar 2004 00:09:13 +0000
Subject: Re: add lowpower_idle sysctl
Message-Id: <20040318160913.5915281d.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040317170436.430acfbe.akpm@osdl.org>
	<200403180318.i2I3IDF03166@unix-os.sc.intel.com>
	<20040317192821.1fe90f24.akpm@osdl.org>
	<Pine.LNX.4.58.0403172237470.28447@montezuma.fsmlabs.com>
	<405A29EA.6000400@mvista.com>
In-Reply-To: <405A29EA.6000400@mvista.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Todd Poynor <tpoynor@mvista.com>
Cc: zwane@linuxpower.ca, kenneth.w.chen@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, cpufreq@www.linux.org.uk

Todd Poynor <tpoynor@mvista.com> wrote:
>
> Zwane Mwaikambo wrote:
> 
> >>Set some system-wide integer via a sysctl and let the particular
> >>architecture decide how best to implement the currently-selected idle mode?
> > 
> > I'm wondering whether the setting of these magic numbers can't be done
> > using cpufreq infrastructure.
> 
> I'd vote for using Patrick Mochel's PM subsystem and use a standard set 
> of identifiers that are mapped to a platform-specific idle behavior, in 
> much the same way as platform suspend modes are handled today.  For 
> example, strings echoed to /sys/power/idle could be an interface.  If 
> folks are amenable to this I'd be happy to supply a (generic) patch for it.

That sounds suitable, thanks.
