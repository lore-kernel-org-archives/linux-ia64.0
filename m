From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 30 May 2002 05:58:35 +0000
Subject: Re: [Linux-ia64] Missing files in to-linus-2.5 BK tree; build problems
Message-Id: <marc-linux-ia64-105590701905620@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905608@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905608@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 30 May 2002 15:49:57 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> It seems to me that it *should* be possible to get all except
  Peter> category 2 synced into the mainline code.  One of the things
  Peter> I've been trying to do occasionally is to compile a
  Peter> ia64-patched kernel on different architectures to see what
  Peter> breaks.  Surprisingly little does.

Yes, absolutely.  I'm working on that, but it's slower than I'd like
it to be.  The DRM patches are next, but not being a DRM expert
doesn't help.  Of course, I always appreciate help (as long as I'm
informed on who's submitting what).

  Peter> BTW, I upgraded the BIOS on lemon.gelato.unsw.edu.au, the
  Peter> machine that had the time haring off into the future.  It
  Peter> seems OK now.

Great!

  Peter> One of the BIOS notes said that the AGP aperture for the
  Peter> I460GX was fixed not to overlap the PCI space.  Does this
  Peter> mean that some of the hacks in the DRM are no longer
  Peter> necessary?

I don't think so.  The "hacks" are not workarounds; they reflect the
fact that on Itanium, CPU accesses to (AGP) memory do not go through
AGP GART translation (somebody please correct me if I got the details
wrong...).

	--david

