From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 05 Jan 2004 22:06:55 +0000
Subject: RE: segv at strcmp
Message-Id: <16377.57343.186978.712093@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
In-Reply-To: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 5 Jan 2004 11:19:36 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> Hi - The gcc version is gcc-3.2-29 and the flags we pass to gcc
  >> are : -O -ansi -fwritable-strings -fsigned-char -D_GNU_SOURCE
  >> -D_REENTRANT

  Tony> I have gcc 3.2.3 ... but it appears to not do anything strange
  Tony> to my test program with those options.

  Tony> main() { char *x = "7chars!";

  Tony>         strcmp(x, "This is 24 chars long!!!"); }

  Tony> with those options.  Do you have any include files that might
  Tony> be redefining strcmp as memcmp?

In earlier versions of libc, there were some mem/str-related routines
which were too aggressive in prefetching.  Perhaps Jes remembers the
details, but I'd definitely recommend to make sure you're running the
latest libc for your distro.

	--david
