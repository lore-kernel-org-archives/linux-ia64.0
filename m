From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 11 Dec 2001 00:44:42 +0000
Subject: Re: [Linux-ia64] pio barriers
Message-Id: <marc-linux-ia64-105590698805677@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805669@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805669@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Dec 2001 16:23:00 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> On Mon, Dec 10, 2001 at 03:58:19PM -0800, David Mosberger wrote:
  >> The comment is wrong, or at least misleading (I wrote it, so hopefully
  >> nobody is offended... ;-).  mf.a is needed for inX/outX emulation, not
  >> really for ordering.  Uncached accesses are not re-ordered by the CPU
  >> and mf will do just fine as far as ordering of cached accesses are
  >> concerned.

  Jesse> On our platform, uncached accesses can arrive out of orderif they come
  Jesse> from different cpus, so simple spinlock protection isn't quite enough
  Jesse> to guarantee that pios don't arrive out of order.  We'll need a pio
  Jesse> barrier macro and (ideally) an spin_unlock variant that includes it.

Yes, I realize that, but it's not the CPU that's reordering the access
so mf doesn't help and mf.a really doesn't guarantee anything either
(though it may on your platform).

  >> Can you get away with forcing the proper ordering with a dummy-read?
  >> If so, I suspect that would be preferable as that is the only platform
  >> independent way to do this (as far as I know).

  Jesse> Do you mean that a driver should do a dummy read following writes that
  Jesse> have to arrive prior to others?  I guess that would be just as
  Jesse> invasive as introducing a pio barrier or another spinlock...

Invasive, yes.  But on some platforms there may be no other way of
enforcing order.  Perhaps what would be best would be a macro that
takes a device address as an argument.  Depending on platform, you
could then do a dummy read from this address or use a special
instruction, such as mf.a, to enforce order.

	--david

