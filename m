From: Jesse Barnes <jbarnes@virtuousgeek.org>
Date: Fri, 20 Jan 2006 17:36:20 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601200936.21111.jbarnes@virtuousgeek.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com> <200601191818.43157.jbarnes@virtuousgeek.org> <20060120003303.O81637@chenjesu.americas.sgi.com>
In-Reply-To: <20060120003303.O81637@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jes@sgi.com, tony.luck@intel.com

On Thursday, January 19, 2006 10:47 pm, Brent Casavant wrote:
> On Thu, 19 Jan 2006, Jesse Barnes wrote:
> > Maybe you could just turn the above into mmiowb() calls instead? 
> > That would cover altix, origin, and ppc as well I think.  On other
> > platforms it would be a complete no-op.
>
> As you obviously noted, the core of the code was lifted from mmiowb().
> But no, an mmiowb() as such isn't correct.  At the time this code is
> executing, it's on a CPU remote from the one which issued any PIO
> writes to the device.  So in this case we need to poll the Shub
> register for a remote node, but mmiowb() only polls for the Shub
> corresponding to the current CPU.

Ah, ok.  It sounds like Ingo might have a better place to put it anyway.  
(I was thinking this was on the switch out path on the CPU where the 
task last ran, didn't look at it in detail.)

Of course, the other option is just to require tasks that do MMIO 
accesses from userspace to be pinned to particular CPU or node. :)

Thanks,
Jesse
