From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jul 2003 23:34:38 +0000
Subject: 2.5.75 out
Message-Id: <marc-linux-ia64-105788013113852@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As you may have seen, Linus just released 2.5.75, which will be the
last kernel in the 2.5 series (next one will be pre-2.6).  If you've
been procrastinating with testing 2.5, now might be a good time to get
going... ;-)

There is good and bad news: the bad news is that 2.5.75 doesn't work
out-of-the-box on ia64.  The good news it _does_ compile.  The thing
that keeps it from working are a few (late) per-CPU related changes.
Hopefully, we can iron those out before pre-2.6 comes out so that it
will build _and_ work.  Probably wishful thinking though.  There
always seems to be that last-minute patch that breaks things...

	--david
