From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Mar 2003 23:54:50 +0000
Subject: Re: [Linux-ia64] provide /proc/sal/itc_drift through AUX?
Message-Id: <marc-linux-ia64-105590723705275@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705273@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705273@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Mar 2003 16:39:31 -0500, Jes Sorensen <jes@wildopensource.com> said:

  Jes> Hi I was wondering what people think about providing the
  Jes> information of /proc/sal/itc_drift as an AUX vector?

  Jes> The problem is that on some NUMA boxen (such as the SGI boxes),
  Jes> the ITC isn't synchronized across nodes and we can't rely on
  Jes> ar.itc in userland for implementing the high-precision
  Jes> timing. I believe the IBM NUMA-Q team has a similar problem
  Jes> that could be solved in a similar way on ia32?

  Jes> Instead one can switch to using gettimeofday() for the timing,
  Jes> which with the new fast syscalls should be quite pleasant.

  Jes> I have a patch which implements this for glibc-2.2 (will do 2.3
  Jes> later), however what I don't like about it is that one ends up
  Jes> opening and reading /proc/sal/itc_drift in every single binary
  Jes> executed. To avoid the overhead of this it seems a good idea to
  Jes> me to provide this information via an AUX vector.

  Jes> If anybody is interested in the glibc patch, feel free to grab
  Jes> it from
  Jes> http://www.wildopensource.com/~jes/glibc/itc-drift-patch.diff
  Jes> For now it's a test patch, though it does seem to behave as
  Jes> expected.

  Jes> Thoughts?

Why do you need to export it if you just use a light-weight
gettimeofday()?  The light-weight syscall can readily access the
ITC-drift info via kernel memory.

BTW: I think someone should explore using an NTP-like approach to keep
ITC drift small enough that it's still usable for ITC-based
interpolation.  Granted, this assumes that hw drifts are reasonably
small and you'd still need to worry about different clock-frequencies,
but I suspect that in practice, this would work extremely well.  It
would be nice because it would be much faster than an HPET-based
approach, would work on all ia64 machines, and would provide better
resolution.  Furthermore, we already have all the logic in the
time-interpolation to ensure that there is never an observable time
discontinuity.

	--david

