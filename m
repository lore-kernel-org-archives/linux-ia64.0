From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 28 Oct 2004 07:14:01 +0000
Subject: Re: Making NUMA/ACPI Kconfig options more explicit
Message-Id: <16768.39993.487360.655689@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041028023656.GA13721@cse.unsw.EDU.AU>
In-Reply-To: <20041028023656.GA13721@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Oct 2004 12:36:56 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> Hi, This trivial suggested patch does the following :

  Ian>  - IA64 won't work without ACPI, so turn it on

Doesn't this break the Ski version of the kernel?

	--david
