From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 06:21:00 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <16576.5324.963519.166097@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 04 Jun 2004 07:08:18 +0200, Andreas Jaeger <aj@suse.de> said:

  Andreas> We're speaking here about native code - and not emulations.
  Andreas> So, for ia64 I only see two native codes right now: 64-bit
  Andreas> code as it is and code using 32-bit pointers (don't know
  Andreas> how it's called).

That'd be ia64/ILP32, which isn't supported on Linux (or Windows,
though it is on HP-UX).

  Andreas> And x86 on ppc64 would be an emulation - not the native code - and
  Andreas> would end somewhere else.

Yep.

  Andreas> Note that what your table says about ppc64 and x86-64 above
  Andreas> is correct - and you can add s390, mips and sparc64 under
  Andreas> the same line.  Sparc has done this for a long time
  Andreas> already.

Yep.

  Andreas> I don't know what Red Hat is doing with x86 and with lib64 - and you
  Andreas> really should ask them for clarification.

Certainly.  I only wished Red Hat would be more
willing/interested/active in discussing such things on public mailing
lists.

  Andreas> Footnotes:
  Andreas> [1]  Note I'm more concerned with x86-64, I'm not advocating here
  Andreas> anything for ia64.

No problem.  I just wanted to make it clear why I think it would be
short-sighted to pub x86 libraries in /usr/lib on ia64.

	--david
