From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 24 Sep 2003 18:02:21 +0000
Subject: Re: [PATCH] do_gettimeofday() fails to compensate for lost ticks
Message-Id: <marc-linux-ia64-106442674331918@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442430128845@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442430128845@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Sep 2003 11:21:19 -0600 (MDT), Khalid Aziz <khalid@fc.hp.com> said:

  Khalid> do_gettimeofday() needs to account for lost ticks before
  Khalid> returning current time and it fails to do
  Khalid> that. do_gettimeofday() on other architectures compensate
  Khalid> for lost ticks correctly. Due to this bug, if you repeatedly
  Khalid> do clock_settime() immediately followed by clock_gettime()
  Khalid> and compare the time returned by clock_gettime() to the time
  Khalid> set by clock_settime(), you will eventually see clock going
  Khalid> backwards. I am attaching a test program from POSIX
  Khalid> testsuite at the end that exposes this bug. Run this test in
  Khalid> a continuous loop that stops when test fails.

This explanation doesn't sound right.  See the "lost" variable in
gettimeoffset().  It's supposed to account for lost ticks.

	--david

