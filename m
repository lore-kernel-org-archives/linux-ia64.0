From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 10 Dec 2001 23:58:19 +0000
Subject: Re: [Linux-ia64] pio barriers
Message-Id: <marc-linux-ia64-105590698805673@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805669@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805669@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Dec 2001 14:47:40 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> I noticed that in asm-ia64/system.h there's a comment that reads:
  Jesse> /*
  Jesse> ...
  Jesse> * Note: "mb()" and its variants cannot be used as a fence to order
  Jesse> * accesses to memory mapped I/O registers.  For that, mf.a needs to
  Jesse> * be used.  However, we don't want to always use mf.a because (a)
  Jesse> * it's (presumably) much slower than mf and (b) mf.a is supported for
  Jesse> * sequential memory pages only.
  Jesse> */

  Jesse> Is there a macro (e.g. piob() or mmiob()) to wrap mf.a or are users
  Jesse> expected to call it explicitly when they need it?  If there is no
  Jesse> macro, I'd like to add one, as I think it will be necessary to
  Jesse> properly support our NUMA platform.

The comment is wrong, or at least misleading (I wrote it, so hopefully
nobody is offended... ;-).  mf.a is needed for inX/outX emulation, not
really for ordering.  Uncached accesses are not re-ordered by the CPU
and mf will do just fine as far as ordering of cached accesses are
concerned.

Platform-acceptance is a tricky business, as it's, well, platform
dependent (note that "mf.a" doesn't really guarantee to do anything).

Can you get away with forcing the proper ordering with a dummy-read?
If so, I suspect that would be preferable as that is the only platform
independent way to do this (as far as I know).

	--david

