From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 23 Aug 2003 17:32:20 +0000
Subject: Re: Why sim/boot in -test4?
Message-Id: <marc-linux-ia64-106166133115431@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106164660606242@msgid-missing>
In-Reply-To: <marc-linux-ia64-106164660606242@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 23 Aug 2003 14:49:54 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> $ cvs diff -rLINUS_260_TEST3 -rLINUS_260_TEST4 arch/ia64/Makefile 
  Matthew> [...]
  Matthew> -boot := arch/ia64/boot
  Matthew> +boot := arch/ia64/hp/sim/boot

  Matthew> Why was this change made?  It's not causing me any
  Matthew> problems, just a bit of confusion when I noticed my
  Matthew> previous vmlinux.gz wasn't getting updated any more.

It's just a general cleanup.  The bootloader ended up never being used
for anything other than the simulator, so moving it to hp/sim makes sense.

Are you saying "make compressed" doesn't build vmlinux.gz anymore?  It
seems to work for me.

	--david
