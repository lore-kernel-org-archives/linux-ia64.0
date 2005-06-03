From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 03 Jun 2005 04:56:14 +0000
Subject: Re: [RFC] ia64 function return probes
Message-Id: <17055.58094.61614.587435@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506012139.j51LdMhY031546@linux.jf.intel.com>
	<7459.1117765049@kao2.melbourne.sgi.com>
In-Reply-To: <7459.1117765049@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@ocs.com.au>
Cc: Rusty Lynch <rusty.lynch@intel.com>, linux-ia64@vger.kernel.org, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, linux-kernel@vger.kernel.org, systemtap@sources.redhat.com, Hien Nguyen <hien@us.ibm.com>

>>>>> On Fri, 03 Jun 2005 12:17:29 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> * arch_prepare_kretprobe() bumps sp by 16 bytes, to account
  Keith> for the saved b0 and ar.pfs.

What if function arguments are being passed on the stack (e.g., more
than 8 scalar arguments)?

	--david
