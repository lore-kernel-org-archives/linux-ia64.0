From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 22 Sep 2003 22:04:25 +0000
Subject: Re: [HELP] latest discontig
Message-Id: <marc-linux-ia64-106426828601134@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106305453930076@msgid-missing>
In-Reply-To: <marc-linux-ia64-106305453930076@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 22 Sep 2003 14:04:46 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> See
  Jesse> http://linux-acpi.bkbits.net:8080/linux-acpi-test-2.6.0/cset@1.1323.1.3?nav=index.html|ChangeSet@-4d.
  Jesse> It'll be part of Len's next push.

Please hold back that patch until Len pushes his changes.  I really
don't want to break things that are already working.

  Jesse> Sorry I should have kept that in the patch so as not to
  Jesse> confuse people.  I've been working hard to get all of the
  Jesse> non-ia64 specific code out into Linus' tree already,
  Jesse> including some bootmem allocator fixes and such, this one
  Jesse> just took a little longer because Andy stepped down as
  Jesse> maintainer at around the same time I sent my (trivial) patch
  Jesse> out to fix this.

OK.

  Jesse> Btw, which piece(s) of the patch would you like first?  Is
  Jesse> seperating the contig and discontig functions into seperate
  Jesse> files worthwhile?  I can comment things a bit more too while
  Jesse> I'm at it...

Sure, that sounds good.

	--david
