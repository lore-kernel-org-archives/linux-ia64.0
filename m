From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Feb 2005 22:29:05 +0000
Subject: RE: porting to ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E2BC10@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107986903.23187.23.camel@oshawa.rd.discreet.qc.ca>
In-Reply-To: <1107986903.23187.23.camel@oshawa.rd.discreet.qc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> return (flags & X86_EFLAGS_IF) 

I suspect that "irqs_disabled()" does what you want (and is
portable between x86, ia64 and others).

-Tony
