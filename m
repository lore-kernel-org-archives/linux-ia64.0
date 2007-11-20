From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 20 Nov 2007 02:58:07 +0000
Subject: Re: [patch 1/1] ia64: increase .data.patch offset
Message-Id: <87myt9lj28.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
In-Reply-To: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

>>>>> "Tony" = Tony Luck <Luck> writes:

>>> What I'll do today, is try a number of different compiler version
>>> (it's realtively easy for me to do this), and email tomorrow which
>>> ones compile a generic kernel, and if I have time, which ones
>>> boot.

It took me a bit longer, because all the native compilers Just Work (tm).

Tony> Are some versions of the compiler actually broken (and
Tony> generating spurious stuff so overflowing this section) ... or
Tony> are we just skating close to the edge so that minor differences
Tony> in generated code push us over the limit.

It appears that crosstool builds some buggy cross compilers.

All the native compilers work fine; I tested from 3.3 to 4.1 (4.2 and
4.3-snapshot fail to compile gensparse_defconfig and tiger_defconfig
because of bug 31490 in the GCC bugzilla).

Cross-compilers from www.emdebian.org work fine (tried 3.3, 3.4, 3.5,
4.0 and 4.1)

Cross compilers using binutils 2.15 built using crosstool fail.
Cross compilers using later binutils may work (I only tried 4.1 which
worked).

Currently there should be plenty of room in the dynamic segment.  It
starts at 0xa0...2a0 and ends at 0xa0...3E0 with all working
compilers.

Andrew, if you use Debian on your test system there's an apt-gettable
archive at http://www.emdebian.org/debian unstable containing cross
compilers, libraries etc., prebuilt for AMD64 and IA32.

Do:
	apt-get install gcc-4.1-ia64-linux-gnu
to get a compiler and all the libraries headers etc., you need.  Much
easier than crosstool.
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
