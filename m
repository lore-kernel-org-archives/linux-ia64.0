From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 17:50:22 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705690@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 8 May 2003 10:20:05 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  >> A new concern though: I don't think text-replication will work
  >> well with this scheme.  If each replica is linked for a different
  >> address, function pointers become a performance problem: whenever
  >> you call through a function pointer, you'll end up executing on
  >> whatever replica initialized the function pointer.  Not good.

  Jesse> Right, I thought about that.  I don't think we need text
  Jesse> replication yet though anyway (at least our platform
  Jesse> doesn't).

That's what I would have guessed.  I think it might be different for
the 8870 chipset though.  Or does it have a huge L4 cache, too?

  >> If we do have to go the virtual remapping route, my preference
  >> would be to stick the kernel somewhere in region 5 (0xa..).  Has
  >> anyone tried that?  It should work fine in principle (modules
  >> already live in that space).

  Jesse> I guess we can revisit that if we need/want to implement text
  Jesse> replication at some point in the future.  It might not be
  Jesse> that bad though--I don't envision relocating each replica,
  Jesse> but rather just seperating the kernel text and data with the
  Jesse> right translation registers that point to local text and
  Jesse> global data, but I haven't thought about it much (this is
  Jesse> what Tony's original patch did, and it seemed to work well).

But it would be rather painful to switch to the "kernel may live at
any address" model just to discover that a year later we're going to
map it virtually anyhow (in which case, the kernel could live at a
fixed address again).

	--david

