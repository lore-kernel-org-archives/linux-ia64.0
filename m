From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Jun 2005 20:37:07 +0000
Subject: Re: [patch][ia64]Refuse kprobe on ivt code- take 2
Message-Id: <17084.28403.603616.786034@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050623172832.B26121@unix-os.sc.intel.com>
	<17083.25625.991516.736507@napali.hpl.hp.com>
	<20050624114545.A4826@unix-os.sc.intel.com>
	<17084.23214.237084.224128@napali.hpl.hp.com>
	<20050624122333.A5213@unix-os.sc.intel.com>
In-Reply-To: <20050624122333.A5213@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: davidm@hpl.hp.com, akpm@osdl.org, Linux Kernel <linux-kernel@vger.kernel.org>, Linux IA64 <linux-ia64@vger.kernel.org>

>>>>> On Fri, 24 Jun 2005 12:23:33 -0700, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com> said:

  Anil> On Fri, Jun 24, 2005 at 12:10:38PM -0700, David Mosberger wrote:
  >> >>>>> On Fri, 24 Jun 2005 11:45:46 -0700, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com> said:
  >> Surely you meant to use the declaration from sections.h instead?

  Anil> Take 1: This patch is based on review comments from David Mosberger,
  Anil> now checking based on .text.ivt
  Anil> Take 2: now including sections.h :-)

Looks fine to me.

Thanks,

	--david
