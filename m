From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Sep 2003 01:57:36 +0000
Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106315916306108@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Sep 2003 10:53:17 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> On Wed, Aug 13, 2003 at 10:07:51AM +1000, Ian Wienand wrote:

  >> We're still working on automated testing (i.e. booting on the
  >> simulator, maybe real hardware).

  Ian> For those who are interested, we now attempt to boot the autobuilt
  Ian> kernels on the simulator daily.  See

  Ian> http://www.gelato.unsw.edu.au/kerncomp/simboot.php

Very nice! (The test setup & web-page, not the fact that the boot
failed... ;-).

As for perfmon under Ski: the latest perfmon should have the necessary
code, but I don't remember whether it made it into test5 already (and
I don't have CONFIG_PERFMON enabled in my Ski setup).  If it's not
there already, it should be there tomorrow, as Linus pulled on the
ia64 repository a couple of hours ago.

	--david
