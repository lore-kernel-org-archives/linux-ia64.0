From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Nov 2003 20:33:17 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927403504014@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Nov 2003 20:20:20 +0000, Matthew Wilcox <willy@debian.org> said:

  >>  And yet both features are incredibly useful when debugging,
  >> something you seem to ignore.

  Matthew> No, it *isn't*.  The majority of systems in use are not
  Matthew> being debugged (regardless of how you & I spend most of our
  Matthew> time).

Please read my sentence: it's incredibly useful when _debugging_ a
problem.

Nobody suggests to print those messages for normal users.  dmesg -n4
will take care of them for good.

  Matthew> Every time we emit something to the system log, it's a
  Matthew> potential support call.  Our friends in other parts of HP
  Matthew> are already unhappy with how much output Linux produces
  Matthew> even when everything's OK.  It's also a sysadmin hassle as
  Matthew> logfiles fill up more quickly when this kind of junk goes
  Matthew> by.

Can I say dmesg -n4??

  Matthew> I'm sure this was useful for debugging once, but those days
  Matthew> are gone.  We need to print less of this stuff.  Something
  Matthew> a lot of places do is:

  Matthew> #undef DEBUG

  Matthew> #ifdef DEBUG #define DBG(x...) printk(x) #else #define
  Matthew> DBG(x...)  #endif

  Matthew> Would it mollify you if these printks were turned into
  Matthew> DBGs?

Nope.  dmesg -n4 is adequate.

	--david
