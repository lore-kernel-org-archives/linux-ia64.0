From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 16 Dec 2002 22:12:37 +0000
Subject: Re: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805578@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 16 Dec 2002 20:00:23 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Sorry for the surfeit of exclamation marks but the ia64 unwind code is
  Keith> driving me up the wall.  I want kdb to backtrace correctly, all this
  Keith> garbage data just gets in the way.

Then use gcc-3.2 (or backport the fixes).

	--david

