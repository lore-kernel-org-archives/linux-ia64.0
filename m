From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 17:07:49 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705687@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 8 May 2003 09:07:14 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> So simply linking with 'ld -q' wouldn't be sufficient?  Doesn't that
  Jesse> produce a binary that will boot w/o elilo changes, but can also be
  Jesse> relocated?

Ah, yes, I had forgotten about -q.  It probably would be sufficient.
And the backwards-compatibility it would achieve would definitely be
a plus.

A new concern though: I don't think text-replication will work well
with this scheme.  If each replica is linked for a different address,
function pointers become a performance problem: whenever you call
through a function pointer, you'll end up executing on whatever
replica initialized the function pointer.  Not good.

Unless I'm missing something, kernel relocation is therefore a bit of
a stillborn idea (unless text-replication really isn't all that
important because we all have humongous caches between nodes...).

If we do have to go the virtual remapping route, my preference would
be to stick the kernel somewhere in region 5 (0xa..).  Has anyone
tried that?  It should work fine in principle (modules already live in
that space).

	--david

