From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 03 Jan 2002 00:53:31 +0000
Subject: [Linux-ia64] Re: [piet@sgi.com: Re: kgdb internet/ethernet support and {gcc or gdb} bug on test addr
Message-Id: <marc-linux-ia64-105590698805729@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Piet/Pete> I'm having trouble with GDB on ia64/sn with addresses in
  Piet/Pete> the text segment.  Pointers to functions are being
  Piet/Pete> reported wrong. I tried changing to the latest gcc and
  Piet/Pete> gdb but it hasn't helped. The actual address for a
  Piet/Pete> function will be 0x2000000000037fa8 but it will be
  Piet/Pete> reported as 0x4000000000059ee0 for a large program or
  Piet/Pete> just slightly for a small program as illustrated below. I
  Piet/Pete> wonder if our kernel could be the cause possibly using:

Try linking the program statically.  I think gdb is reporting the
address of the function's plt entry.

	--david

