From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 May 2004 01:35:12 +0000
Subject: Re: Disable CONFIG_SMP for IA64_HP_SIM
Message-Id: <16554.47568.611312.489130@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040519012326.GA27655@cse.unsw.EDU.AU>
In-Reply-To: <20040519012326.GA27655@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 May 2004 11:23:26 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> CONFIG_SMP depends on CONFIG_IOSAPIC to build (maybe this is
  Ian> the real problem, I don't know).

  Ian> CONFIG_IOSAPIC excludes IA64_HP_SIM.  Some sample configs [1]
  Ian> have SMP enabled for the simulator, and it broke my autobuild,
  Ian> so maybe making it explicit would be good?

SMP must work with the simulator.  It's often useful for
testing-purposes, even though Ski simulates only one CPU.

CONFIG_SMP probably shouldn't depend on CONFIG_IOSAPIC.

	--david
