From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Feb 2004 07:37:00 +0000
Subject: Re: gcc problems
Message-Id: <16424.35356.694196.577887@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 6 Feb 2004 08:30:50 -0800, Andrew Morton <akpm@osdl.org> said:

  Andrew> Andreas Schwab <schwab@suse.de> wrote:
  >>  The fields were named differently in old versions of glibc, but
  >> the whole layout didn't change in any way.

  >> - unsigned long int sc_rsvd[16];/* reserved for future use */ +
  >> unsigned long int sc_rbs_base;/* NULL or new base of sighandler's
  >> rbs */ + unsigned long int sc_loadrs; /* see description above */
  >> + unsigned long int sc_ar25; /* cmp8xchg16 uses this */ +
  >> unsigned long int sc_ar26; /* rsvd for scratch use */ + unsigned
  >> long int sc_rsvd[12];/* reserved for future use */

  >> > The easiest workaround is probably to install libunwind on your
  >> system

  >> The right fix is not to use a 2 years old glibc.

  Andrew> That's not very old.  One shouldn't have to upgrade libc
  Andrew> just to build gcc?

True in general, but in this particular case, many bugs have been
fixed in glibc in the meantime, especially with respect to unwinding.
So 2 years is old when trying to build a compiler which has reasonable
support for unwinding.

	--david
