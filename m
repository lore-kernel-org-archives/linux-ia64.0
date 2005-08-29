From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 29 Aug 2005 04:09:02 +0000
Subject: RE: ip_contrack module refuses to load...
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F043F4CB9@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>ip_tables: (C) 2000-2002 Netfilter core team
>ip_conntrack: value -6917529019048071580 out of IMM22 range
>
>in dmesg.
>
>That value doesn't correspond to any symbol I can find in
>/proc/kallsyms (it's A0000002002EEE64: symbols near there are:

What an unhelpful error message!  That value will be the address
in the module that failed to load.  But to do something useful
with it you'd need to know the base address at which the
kernel was loading the module ... but since the load failed,
there is no way to find that.

You might make some intelligent guesses by looking at the low
order PAGE_SHIFT-1 bits, which will remain the same whatever
the base address is.  Use objdump -d, and objdump --reloc on
the ip_conntrack.ko at look at each offset that matches.

-Tony
