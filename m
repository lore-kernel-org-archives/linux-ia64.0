From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 06 Jun 2005 17:25:09 +0000
Subject: Re: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <17060.34549.590302.820704@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 06 Jun 2005 19:04:21 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> David Mosberger <davidm@napali.hpl.hp.com> writes:
  >>>>>>> On Sat, 04 Jun 2005 14:18:16 +1000, Keith Owens <kaos@sgi.com> said:
  >>
  Keith> On Fri, 3 Jun 2005 11:50:55 -0700,
  Keith> "Luck, Tony" <tony.luck@intel.com> wrote:
  >> >>> This explains why XPC has been so troublesome to load on older systems.
  >> >>> Thanks Dean!
  >> >>>
  >> >>> Tony, can this still get into 2.6.12?
  >> >>
  >> >> Probably ... but the first hunk of the patch looks like a no-op,
  >> >> and contravenes some style guidlines about initializing global
  >> >> variables to 0.
  >> >>
  >> >> -static int shub_1_1_found __initdata;
  >> >> +static int __initdata shub_1_1_found = 0;
  >>
  Keith> There is a linker restriction that you must initialise variables that
  Keith> are to be stored in different sections, which is what __initdata does.
  Keith> without initialization shub_1_1_found ends up in .bss, with
  Keith> initialization it ends up in .init.data.

  >> Interesting.  Strikes me as a toolchain-bug, though.  Clearly the
  >> __initdata declaration is in conflict with putting the data in .bss,
  >> yet there is no warning or error.

  Andreas> Can't reproduce that with gcc 3.2, or anything newer.

  Andreas> $ cat section.c
  Andreas> int __attribute__((section(".init.data"))) foo;
  Andreas> $ gcc -S section.c
  Andreas> $ cat section.s
  Andreas> .file	"section.c"
  Andreas> .pred.safe_across_calls p1-p5,p16-p63
  Andreas> .global foo#
  Andreas> .section	.init.data,"aw",@progbits
  Andreas> .align 4
  Andreas> .type	foo#,@object
  Andreas> .size	foo#,4
  Andreas> foo:
  Andreas> .skip	4
  Andreas> .ident	"GCC: (GNU) 3.2.2"

I remembering GCC 3.x getting more picky about section conflicts.  So
perhaps these changes also fixed this particular issue.  Good.  I
guess it's time to declare the documentation officially out-of-date?

	--david
