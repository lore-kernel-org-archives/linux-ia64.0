From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 26 Aug 2003 20:58:46 +0000
Subject: Re: [PATCH] ia64 oprofile support for 2.6.0-test4
Message-Id: <marc-linux-ia64-106193176908925@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106193081107734@msgid-missing>
In-Reply-To: <marc-linux-ia64-106193081107734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 26 Aug 2003 16:42:27 -0400, Will Cohen <wcohen@redhat.com> said:

  Will> +	eip = instruction_pointer(regs);

eip?  How about calling it "ip", which is the register name and what's
used everywhere else in the ia64 tree.

  Will> +/*
  Will> + * We use the ia64_psr(regs)->ri to determine which of the three
  Will> + * instructions in bundle took the sample. The instructions in the
  Will> + * ia64 do not fall on nice four byte boundaries, so there is no point
  Will> + * in multiplying ia64_psr(regs)->ri by 4.
  Will> + */
  Will> +#define instruction_pointer(regs) ((regs)->cr_iip + ia64_psr(regs)->ri)

How are you going to get instruction-level precision with this?

Given this:

  Will> -	ip >>= prof_shift;

you'd have to use a prof_shift of 0, which is wasteful.  If you
multiply ri by 4, you can use a prof_shift of 2, reducing the
histogram size by a factor of 4 while still getting instruction-level
accuracy.

I can see why you don't want to do the multiply-by-four in
instruction_pointer(), but if that's what you want to avoid, I think
ia64_do_profile() should should do it so we can get the desired
effect.

	--david
