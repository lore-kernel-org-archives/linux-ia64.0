From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 26 Mar 2005 00:59:04 +0000
Subject: Re: [patch] lfetch.fault [NULL] speedup
Message-Id: <16964.46040.699345.631759@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16964.41018.199600.952301@napali.hpl.hp.com>
In-Reply-To: <16964.41018.199600.952301@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 26 Mar 2005 11:47:30 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Fri, 25 Mar 2005 15:35:22 -0800,
  Keith> David Mosberger <davidm@napali.hpl.hp.com> wrote:
  >> === arch/ia64/kernel/ivt.S 1.34 vs edited ==  >> --- 1.34/arch/ia64/kernel/ivt.S	2005-03-24 14:06:40 -08:00
  >> +++ edited/arch/ia64/kernel/ivt.S	2005-03-25 15:13:07 -08:00
  >> @@ -1235,6 +1235,25 @@
  >> // 0x5600 Entry 26 (size 16 bundles) Nat Consumption (11,23,37,50)
  >> ENTRY(nat_consumption)
  >> DBG_FAULT(26)
  >> +
  >> +	mov r16=cr.ipsr
  >> +	mov r17=cr.isr
  >> +	mov r31=pr				// save PR
  >> +	cmp.ne p6=r0,r0				// p6 = FALSE
  >> +	;;
  >> +	and r18=0xf,r17				// r18 = cr.ipsr.code{3:0}
  >> +	tbit.z.or p6,p0=r17,IA64_ISR_NA_BIT
  >> +	;;
  >> +	cmp.ne.or p6,p0=IA64_ISR_CODE_LFETCH,r18

  Keith> Why use tbit.*.or and cmp.*.or?  The normal form works just as well in
  Keith> this case (r17 cannot be NaT) and the normal form does not need cmp.ne
  Keith> p6=r0,r0 first.

Sure, that's fine.  It's a left-over because originally I was planning
to have the tbit.z and cmp.ne.or in the same instruction-group.

It doesn't matter though: execution-time is completely dominated by
the time to read and write the control registers.

	--david
