From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 26 May 2005 19:40:53 +0000
Subject: Re: [patch 1/4] Kprobes support for IA64
Message-Id: <17046.9797.422792.800821@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <429484F2.8080401@hp.com>
	<12169.1117068542@ocs3.ocs.com.au>
	<20050525180652.B10277@unix-os.sc.intel.com>
In-Reply-To: <20050525180652.B10277@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: Keith Owens <kaos@sgi.com>, "Alan D. Brunelle" <Alan.Brunelle@hp.com>, "Lynch, Rusty" <rusty.lynch@intel.com>, akpm@osdl.org, "Luck, Tony" <tony.luck@intel.com>, "Seth, Rohit" <rohit.seth@intel.com>, prasanna@in.ibm.com, ananth@in.ibm.com, systemtap@sources.redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> On Wed, 25 May 2005 18:06:52 -0700, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com> said:

  Keshavamurthy> I agree with Keith, when a person taking a instructin
  Keshavamurthy> dump, a different value will help uniquely identify
  Keshavamurthy> that this is a kprobe break instruction which is a
  Keshavamurthy> replaced instrucion of the original instruction. So
  Keshavamurthy> we will leave with what we have now, i.e handle the
  Keshavamurthy> same with two cases.

We could read the imm21 value from the break.b instruction.

	--david
