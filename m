From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 29 Oct 2001 18:28:54 +0000
Subject: Re: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805408@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805400@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805400@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 29 Oct 2001 10:10:44 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> Regarding glibc though: we really don't want to have a
  Jesse> different version just for our systems, so I'd like to come
  Jesse> up with a generic solution.

Oh, yes, I guess I wasn't quite clear in my response: the "ITC are
synchronous" flag needs to be exported to user level (probably through
a /proc file).  glibc then reads that flag and if the ITCs are *not*
synchronous, it has two choices:

	- if there is a driver for a fine-grained machine timer, it can
	  use it

	- if no such driver exists, it will not be able to provide
	  fine grained time stamps

So, you'll have to define and implement a driver interface to your
machine timer (on SN1 its in the chipset, right?).  If you want to go
ahead with this, you might want to take a look at the Intel multimedia
timer spec as well.  I have my issues with that spec (it doesn't
provide sufficient alignment guarantees, in my opiniono), but
considering it should help in designing an interface that will be
useful not just for SGI machines, but for all "big" ia64 machines.

  Jesse> Maybe an ia64 specific clock driver that glibc could map in
  Jesse> to read synchronized clock info?

Yup.  The driver interface needs to allow direct user-level access to
the fine grained timer.  Though I'd say the interface should be able
to accommodate hardware that can't map the timer into user space.

	--david

