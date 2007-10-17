From: peterc@gelato.unsw.edu.au
Date: Wed, 17 Oct 2007 04:36:27 +0000
Subject: Re: [PATCH 9/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <87d4vexsqc.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4714BF9C.6090308@jp.fujitsu.com>
In-Reply-To: <4714BF9C.6090308@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

>>>>> "Hidetoshi" = Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> writes:
>>> [9/9] ia64_acct_get_vtime.patch
Peter> trying to do this stuff.  Things to watch are: -- With Montvale
Peter> and later, the processor clock speed can be varied via ACPI.
Peter> Does ITC rate change?  

I've checked ... according to the latest IA-64 System Architecture,
ITC runs at constant rate even if the instruction execution rate
changes.  So you're safe.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia


