From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 06 Jun 2005 16:57:58 +0000
Subject: Re: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <17060.32918.154655.8550@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 04 Jun 2005 14:18:16 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> On Fri, 3 Jun 2005 11:50:55 -0700, 
  Keith> "Luck, Tony" <tony.luck@intel.com> wrote:
  >>> This explains why XPC has been so troublesome to load on older systems.
  >>> Thanks Dean!
  >>> 
  >>> Tony, can this still get into 2.6.12?
  >> 
  >> Probably ... but the first hunk of the patch looks like a no-op,
  >> and contravenes some style guidlines about initializing global
  >> variables to 0.
  >> 
  >> -static int shub_1_1_found __initdata;
  >> +static int __initdata shub_1_1_found = 0;

  Keith> There is a linker restriction that you must initialise variables that
  Keith> are to be stored in different sections, which is what __initdata does.
  Keith> without initialization shub_1_1_found ends up in .bss, with
  Keith> initialization it ends up in .init.data.

Interesting.  Strikes me as a toolchain-bug, though.  Clearly the
__initdata declaration is in conflict with putting the data in .bss,
yet there is no warning or error.

	--david
