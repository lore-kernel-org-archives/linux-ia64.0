From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 13 Jun 2002 18:26:35 +0000
Subject: Re: [Linux-ia64] pthread failure ???
Message-Id: <marc-linux-ia64-105590701905672@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905668@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905668@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 13 Jun 2002 13:14:52 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:

  Jack> I undid the patch (below). It still fails.

OK, that's good, actually.

  Jack> - the failure is a SEGV. chunk_free tries to dereference a NULL pointer
  Jack> (plus a small offset).

I'm sure you know this, but SEGV in chunk_free is not unusual when
dynamically allocated memory got corrupted.  So the trick is to track
down where the memory corruption occurred.  Do you have a minimal test
program reproducing the problem?

	--david

