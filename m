From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 29 Oct 2001 15:54:13 +0000
Subject: Re: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805404@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805400@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805400@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Oct 2001 10:09:47 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> David, you mentinoned awhile back that you don't expect the
  Jesse> itc counters to be synchronized in future machines and that
  Jesse> apps should use gettimeofday and the posix clock_* routines
  Jesse> to get timestamps.  However, the clock_* routines in recent
  Jesse> versions of glibc for ia64 look at ar.itc as the source of
  Jesse> clock tick information.  Does that need to be fixed?

Yes.  Uli knows about this.  It's just that we couldn't do anything
about it because there is no way of detecting this case.

  Jesse> This problem is more immediate on our hardware, as the clocks
  Jesse> are not synchronized, so I'd like to come up with a solution.
  Jesse> I'm not sure I understand all the issues yet, but I'd like to
  Jesse> solicit people for ideas and/or explaination about this
  Jesse> issue.

The first thing to do is to get this into the firmware.  Linux needs a
way to detect when the ITCs are not driven off the same clock (i.e.,
when there is a chance for the ITCs to drift).  There also needs to be
a way for detecting when the clock frequencies are different, but I
believe the info provided by PAL/SAL is sufficient (my only worry are
rounding errors...).

	--david

