From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 21 Mar 2003 17:49:14 +0000
Subject: Re: [Linux-ia64] provide /proc/sal/itc_drift through AUX?
Message-Id: <marc-linux-ia64-105590723705284@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705273@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705273@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jes" = Jes Sorensen <jes@wildopensource.com> writes:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
David> No, not at all.  I was simply suggesting to always use
David> gettimeofday().  The light-weight implementation of
David> gettimeofday() runs in ~130 cycles, which isn't much slower
David> than what you could do in user-level.

Jes> Ok, that makes it even simpler, I will do that then.

Thinking about this, I still think we need the patch for glibc-2.2 and
maybe glibc-2.3 for compiling with kernels < 2.5.x? Though I'd
probably just say we should take the hit for people using 2.4 kernels
with glibc-2.3. The fast syscall support isn't going into glibc-2.2.

I assume some of the BuzzwordCompliantServer packages from various
distributions are going to stick to glibc-2.2 and kernel-2.4.x for a
while.

Back to mangling glibc-2.3.

Cheers,
Jes

