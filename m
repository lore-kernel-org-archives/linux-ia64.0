From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 18 Aug 2003 20:52:19 +0000
Subject: Re: ia64 2.6.0-test3 crashes on IOZone
Message-Id: <marc-linux-ia64-106124149018025@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106098668517415@msgid-missing>
In-Reply-To: <marc-linux-ia64-106098668517415@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 16 Aug 2003 17:40:53 -0700, Evan Felix <evan.felix@pnl.gov> said:

  Evan> I compiled the kernel with the debian unstable gcc 3.2:
  Evan> Reading specs from /usr/lib/gcc-lib/ia64-linux/3.2.3/specs

OK.  While I don't use this compiler myself, it should be OK.

  Evan> if it matters this was a bk pull from linus's tree that claimed to be
  Evan> 2.6.0-test3...

That should be OK.  I did release an ia64-specific patch in the
meantime.  I don't really expect it to make a difference for you
problem, though (you might want to try it just to be on the safe
side).

  Evan> also is there any reason i did not get more of the stack trace
  Evan> from the kernel?

It might indicate stack corruption.  Which brings me to the next
question: what filesystem were you using?  I used ext3.

	--david
