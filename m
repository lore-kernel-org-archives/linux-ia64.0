From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Nov 2003 20:13:33 +0000
Subject: Re: qla2xxxx driver for IA64
Message-Id: <marc-linux-ia64-106927282802248@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926349321842@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926349321842@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Nov 2003 09:10:34 -0800, Evan Felix <evan.felix@pnl.gov> said:

  Evan> the IA64 ioctl.h file did not hav the _IOXX_BAD macros, and i
  Evan> added them, i'm not sure how safe that was, but it compiled.

Last time I checked, the _IOXX_BAD macros were not used anywhere in
the standard kernel and that's why I leaned against including them
(they seemed like a very temporary thing to me).  Perhaps the driver
could be fixed instead to not use the bad macros?

	--david
