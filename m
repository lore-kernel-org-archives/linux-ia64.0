From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 May 2003 19:30:31 +0000
Subject: Re: [Linux-ia64] kernel 2.5.69 doesn't compile for UP
Message-Id: <marc-linux-ia64-105590723705807@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705787@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705787@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 May 2003 19:05:45 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> Yes, I'd love to ;-) I just need to fix your 2.5.69 patch
  Matthew> so it'll compile :-P $ find -type f |xargs grep
  Matthew> compat_sys_setaffinity ./arch/ia64/ia32/ia32_entry.S: data8

The ia32 subsystem does NOT work at the moment, as I mentioned in my
announcement.  If you chose to ignore my messages, tough luck.

  Matthew> Seriously, this is an attitude I see way too much of in
  Matthew> this port.  Something's broken so it gets kludged inside
  Matthew> arch/ia64 (or worse yet,

It's always nice to hear your opinions.

  Matthew> Maybe it's a relic of the "secret beginnings" of this port,
  Matthew> or maybe people from certain companies have too narrow a
  Matthew> focus, but it has to stop.  I think the attitude is
  Matthew> starting to change but there's a lot of cruft built up.

Oh, yeah, bring out your conspiracy theories.  Yawn.

Perhaps you might want to consider a more obvious scenario?  Like,
there is much more work to go around than time/people to do it all and
hence certain things get lower priority?

In fact, why not start with yourself?  If you see something that you
absolutely hate, send in a patch to fix it.  That's how Linux works.

	--david

