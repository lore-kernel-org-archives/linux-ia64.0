From: Zwane Mwaikambo <zwane@linuxpower.ca>
Date: Thu, 18 Mar 2004 03:40:31 +0000
Subject: Re: add lowpower_idle sysctl
Message-Id: <Pine.LNX.4.58.0403172237470.28447@montezuma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040317170436.430acfbe.akpm@osdl.org>
 <200403180318.i2I3IDF03166@unix-os.sc.intel.com> <20040317192821.1fe90f24.akpm@osdl.org>
In-Reply-To: <20040317192821.1fe90f24.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Kenneth Chen <kenneth.w.chen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, CPU Freq ML <cpufreq@www.linux.org.uk>

On Wed, 17 Mar 2004, Andrew Morton wrote:

> "Kenneth Chen" <kenneth.w.chen@intel.com> wrote:
> >
> >  > > Logically it means a sysctl entry in /proc/sys/kernel.
> >  > Yes, but the *meanings* of the different values of that sysctl need
> >  > to be defined, and documented.  If lowpower_idleB has a totally
> >  > different meaning on different architectures then that's unfortunate
> >  > but understandable.  But we should at least enumerate the different
> >  > values and try to get different architectures to honour `42' in the
> >  > same way.
> >
> >  Writing to sysctl should be a bool, reading the value can be number of
> >  module currently disabled low power idle.  I think the original intent
> >  is to use ref count for enabling/disabling.  (granted, we copied the
> >  code from other arch).
>
> OK, so why not give us:
>
> #define IDLE_HALT			0
> #define IDLE_POLL			1
> #define IDLE_SUPER_LOW_POWER_HALT	2
>
> and so forth (are there any others?).
>
> Set some system-wide integer via a sysctl and let the particular
> architecture decide how best to implement the currently-selected idle mode?

I'm wondering whether the setting of these magic numbers can't be done
using cpufreq infrastructure.

