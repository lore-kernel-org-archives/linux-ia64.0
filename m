From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 24 Sep 2003 19:25:55 +0000
Subject: Re: [PATCH] do_gettimeofday() fails to compensate for lost ticks
Message-Id: <marc-linux-ia64-106443175006295@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442430128845@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442430128845@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Sep 2003 12:58:01 -0600 (MDT), Khalid Aziz <khalid@fc.hp.com> said:

  Khalid> That was it. The same test that failed in less than 30
  Khalid> seconds, now has been running for more than 10 minutes
  Khalid> without failure.

Great!  Thanks for tracking this down.  I'm not surprised this bug has
gone undetected so long---settimeofday() isn't really called all that
often.  I guess this shows the value of a good test-suite...

	--david
