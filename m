From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 25 Aug 2003 20:56:46 +0000
Subject: Re: Why sim/boot in -test4?
Message-Id: <marc-linux-ia64-106184533520478@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106164660606242@msgid-missing>
In-Reply-To: <marc-linux-ia64-106164660606242@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 23 Aug 2003 18:40:55 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> By the way, -test3 used to take a really really long time
  Matthew> to link each step, and -test4 doesn't.  I don't know
  Matthew> whether this was an intentional fix, but I'm certainly
  Matthew> happy to see it.

I don't think it's a fix per se, but rather a new config option: it
used to be that I turned on compilation with "-g" unconditionally
(sorry, but I hate not having debug info around when you need it...).
Now Sam (finally! ;-) added a CONFIG_DEBUG_KERNEL option, so if you
didn't turn this on, the kernel will be compiled without debug option
and the resulting object files will be a lot smaller.

BTW: someone really ought to look into why the debug info is so big
and what could be done to handle it more sanely.  For example, we get
tons of debug-info replication due to header-files etc.  It's rather
embarrassing how low the state of the art is w.r.t. debug info
management...

	--david
