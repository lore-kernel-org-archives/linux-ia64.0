From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 11 Dec 2001 05:30:08 +0000
Subject: Re: [Linux-ia64] pio barriers
Message-Id: <marc-linux-ia64-105590698805680@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805669@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805669@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Dec 2001 16:55:48 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> On Mon, Dec 10, 2001 at 04:44:42PM -0800, David Mosberger
  Jesse> wrote:
  >> Yes, I realize that, but it's not the CPU that's reordering the
  >> access so mf doesn't help and mf.a really doesn't guarantee
  >> anything either (though it may on your platform).

  Jesse> Yeah, that's too bad.  On MIPS we've got 'sync', which is
  Jesse> implemented to do a pio flush.  Apparently IA64 doesn't have
  Jesse> a nice way to do something similiar though, so oh well.

Well, mf.a *does* do something on the 460 chipset.  So I think it's
mostly a platform issue.  Are you saying that on SGI's IA-64 platforms
mf.a doesn't do the equivalent of the MIPS sync?  (Just curious.)

  >> Invasive, yes.  But on some platforms there may be no other way
  >> of enforcing order.  Perhaps what would be best would be a macro
  >> that takes a device address as an argument.  Depending on
  >> platform, you could then do a dummy read from this address or use
  >> a special instruction, such as mf.a, to enforce order.

  Jesse> Can you think of other platforms that might need a device
  Jesse> argument to a potential pio barrier macro?  I was tentatively
  Jesse> thinking of implementing it without any arguments, but I
  Jesse> suppose we could just ignore any arguments for our
  Jesse> platform...

Well, my concern is mostly about the x86 platform.  I assume x86 NUMA
machines would have the same ordering problem, so if we propose a fix
for the problem, we need to make sure it works on x86 too as otherwise
it will not make it into the official tree.

	--david

