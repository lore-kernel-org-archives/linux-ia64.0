From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 24 Feb 2004 21:30:12 +0000
Subject: Re: [PATCH] improve gate generation
Message-Id: <16443.49764.806739.56986@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040224015640.GJ25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040224015640.GJ25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Feb 2004 15:52:48 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Mon, Feb 23, 2004 at 06:08:13PM -0800, David Mosberger wrote:
  >> >>>>> On Tue, 24 Feb 2004 01:56:40 +0000, Matthew Wilcox <willy@debian.org> said:
  Matthew> - Adding the extra-y list prevents it from being rebuilt
  Matthew> unnecessarily.

  >> Ah, so _that's_ the missing magic.

  Matthew> Yeah, it was bugging me too.  Not enough to fix it until I
  Matthew> wanted to run "sudo make install" and of course the output
  Matthew> was then owned by root.  Took me a while to figure it out;
  Matthew> finally I asked myself what the difference was between
  Matthew> gate.lds.s and vmlinux.lds, and vmlinux.lds was in extra-y.
  Matthew> Make does so much that staring at make -d isn't always a
  Matthew> great help.  ("It depends on FORCE.  Hm.  But why doesn't
  Matthew> that other thing depend on FORCE?")

I looked into it briefly at some point, too, but concluded that
perhaps the old behavior was the intended one (perhaps dependencies
don't get tracked properly for all possible cases?).  At least, I
don't see anything mentioned for extra-y on i386 other than
vsyscall-syms.o.

	--david
