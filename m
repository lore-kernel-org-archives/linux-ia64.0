From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Jan 2003 18:15:43 +0000
Subject: Re: [Linux-ia64] Distributions using gcc 3.2 or later
Message-Id: <marc-linux-ia64-105590709805684@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805681@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805681@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 15 Jan 2003 09:43:39 -0800, Perry Wagle <wagle@wirex.com> said:

  Perry> Intel has graciously short-term-loaned me a IA64.  Before
  Perry> Christmas break, I poked around, and all the Linux
  Perry> distributions for IA64 seemed GCC 2.96 based, except for the
  Perry> Redhat rawhide distribution.  But, testing with alpha-test
  Perry> distributions makes me nervous that I would be testing much
  Perry> more than my changes.  Now that my compiler modification is
  Perry> starting to work, I thought I'd poke my head out and ask what
  Perry> distribution I should use that would expect GCC 3.2 or later?

Debian/unstable also uses gcc-3.2.  As you'd expect, this version
isn't as solid as Debian/stable, but it's definitely usable (I'm
running it on my McKinley workstation at work).  The main thing is
that stuff sometimes breaks temporarily (e.g., it seems the X server
broke a couple of days ago), but usually those can be fixed by
downgrading to the "stable" version of the package.

	--david

