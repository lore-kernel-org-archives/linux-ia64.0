From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 10 May 2004 20:16:33 +0000
Subject: Re: [PATCH] new ".serialize" gas directive
Message-Id: <16543.58145.776571.385405@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 07 May 2004 00:48:46 -0700, Jim Wilson <wilson@specifixinc.com> said:

  Jim> I don't have a lot of time for IA-64 gcc work at the moment.  It might
  Jim> be useful to have a gcc bug report for this so we don't lose track of
  Jim> it.

I was going to submit a bug-report, but it's difficult to provide a
reliable test-case, because other changes in the compiler can easily
make one particular warning go away, just to show up in some other
place.  For example, with the CVS gcc (pre-3.5), the warning from
mm/vmscan.c is gone but instead we get several other warnings such as
this one from net/drivers/bonding/bond_main.c:

$ as -x drivers/net/bonding/bond_main.s
drivers/net/bonding/bond_main.s: Assembler messages:
drivers/net/bonding/bond_main.s:3409: Warning: Use of 'addl' may violate WAW dependency 'GR%, % in 1 - 127' (impliedf), specific resource number is 42
drivers/net/bonding/bond_main.s:3408: Warning: This is the location of the conflicting usage

The code in question looks like this:

	cmp4.eq p12, p13 = 6, r14
	addl r28 = @ltoffx(.LC26), r1
	mov r40 = r32 ;;

  (p13) cmp.eq p16, p17 = 0, r34
	ld8.mov r41 = [r28], .LC26
  (p12) br.cond.dpnt .L1108 ;;

  (p16) addl r42 = @ltoffx(.LC28), r1
  (p17) addl r42 = @ltoffx(.LC27), r1

So, I think the best the bug report could say is "try building the
Linux kernel and look for spurious dependency-violation warnings".  Is
this worth putting in a bug-report?

	--david
