From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 04:58:48 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <16576.392.754663.498730@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 01 Jun 2004 11:48:56 +0200, Andreas Jaeger <aj@suse.de> said:

  Andreas> Just a clarification: AMD64 [1] has most of user space
  Andreas> 64-bit.  Only a few applications are 32-bit - but this
  Andreas> lib/lib64 is the best way to handle 32-bit packages (no
  Andreas> need to change files).

  >> Moving to lib32 and lib64 makes sense in that environment.

  Andreas> Not lib32, just lib.

That may be a reasonable solution for x86-64 but I don't think it is
for ia64.  What's needed is multi-architecture support, not bi-arch
support.  Let's consider some possible bi-arch setups:

			contents of:

host arch:	/usr/lib	/usr/lib64
----------
x86-64		x86		x86-64
ia64		x86		ia64
ppc64		ppc32		ppc64

So far, so good.  But what if x86-64 emulation support were added to
Intel's IA32EL?  With the bi-arch-logic, that's either not supported
or you'd have to move the ia64-stuff _again_ from /usr/lib64 into some
other place.  Thanks, but no thanks.  Not to mention that trying to
move ia64 libraries from /usr/lib to /usr/lib64 is almost certainly
worse than any ill it could possibly cure.

Even if you didn't in the above scenario, it wouldn't surprise me if
the ppc64 folks also wanted to be able to run x86 binaries.  If so,
the bi-arch approach won't work for them either, because /usr/lib is
already taken by ppc32.

	--david
