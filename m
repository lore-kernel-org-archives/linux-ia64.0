From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Sep 2003 20:00:03 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106439024820366@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Sep 2003 12:10:44 -0700, "David S. Miller" <davem@redhat.com> said:

  >> Look, this may be difficult for you to understand, but different
  >> people find different policies useful.

  David> You, sure.  But you are not the only user of the ia64 port just
  David> as I am not the only user of the sparc64 port and if sparc64 generated
  David> diagnostic messages not useful to people other than me I'd have to
  David> quiet them by default.

But they _are_ useful.  Peter certainly noticed very quickly that
there was a problem with the ns83820 driver.  Do you think it would
have been better for the kernel to run silently at greatly degraded
performance?  I think not.

The optimistic assumption that the network stack is making about
headers being aligned works as long as unaligned headers are
relatively rare.  If unaligned headers are common, we'll have to do
something about that for ia64 (and Alpha, SPARC, PA-RISC, MIPS, etc.),
because performance will otherwise suck.

BTW: Peter, I'm not quite sure I understand why your machine got into
real problems because of the printks.  The messages are supposed to be
rated limited to at most 5 per 5 second interval.  Each message is
about 80 bytes in size, so we're talking about 80 bytes/s.  Do you
know what really went wrong here?  Did the rate limiting not work as
expected or is there something strange about your setup?

	--david
