From: "Kenneth Chen" <kenneth.w.chen@intel.com>
Date: Thu, 18 Mar 2004 03:18:12 +0000
Subject: RE: add lowpower_idle sysctl
Message-Id: <200403180318.i2I3IDF03166@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040317170436.430acfbe.akpm@osdl.org>
References: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
In-Reply-To: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Andrew Morton' <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> Andrew Morton on Wednesday, March 17, 2004 5:05 PM
> >
> > On ia64, we need runtime control to manage CPU power state in the
> > idle loop.
>
> Can you expand on this?

If architecture provides a facility for low power state, we would like
to turn that on in the idle loop to conserve power.  However, in some
specific situation like for performance, it is desired to be off at
least during that period of time.  A runtime control would allow power
state to be managed dynamically to accommodate both.

That's what we are trying to do: to have a sysctl to control whether
CPU goes into low power state or not in the default_idle() loop. In the
generic code, kernel provides a mechanism to set/clear a flag, and in each
arch, we can then test the flag before entering into low power state.


> Does this mean that the admin can select
> different idle-loop algorithms?  If so, what alternative algorithms exist?

This patch isn't that fancy, nice feature but maybe next step :-)


> > Logically it means a sysctl entry in /proc/sys/kernel.
> Yes, but the *meanings* of the different values of that sysctl need
> to be defined, and documented.  If lowpower_idleB has a totally
> different meaning on different architectures then that's unfortunate
> but understandable.  But we should at least enumerate the different
> values and try to get different architectures to honour `42' in the
> same way.

Writing to sysctl should be a bool, reading the value can be number of
module currently disabled low power idle.  I think the original intent
is to use ref count for enabling/disabling.  (granted, we copied the
code from other arch).


> Needs to be initialised - atomic_t's may have spinlocks inside them or
> anything else.
>
> Needs to be in a header, not in .c
>
> You cannot treat an int* as an atomic_t*!

My monkey work, must be not having enough coffee today :-P

- Ken


