From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 25 Mar 2004 19:20:58 +0000
Subject: RE: add lowpower_idle sysctl
Message-Id: <200403251920.i2PJKwF25849@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <405A29EA.6000400@mvista.com>
References: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
In-Reply-To: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Todd Poynor' <tpoynor@mvista.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, CPU Freq ML <cpufreq@www.linux.org.uk>

>>>>> Todd Poynor wrote on Thu, March 18, 2004 3:00 PM
> I'd vote for using Patrick Mochel's PM subsystem and use a standard
> set of identifiers that are mapped to a platform-specific idle behavior,
> in  much the same way as platform suspend modes are handled today.  For
> example, strings echoed to /sys/power/idle could be an interface.  If
> folks are amenable to this I'd be happy to supply a (generic) patch for it.

Just wondering what is the state of development for this new PM scheme?
I don't check LKML that frequently, sorry if I miss any posting on LKML.

- Ken


