From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 13 Feb 2004 00:14:47 +0000
Subject: Re: [RFC][PATCH] linux-2.6.3-rc2_ia64-cyclone_A0
Message-Id: <16428.5879.170743.384007@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076556140.795.119.camel@cog.beaverton.ibm.com>
In-Reply-To: <1076556140.795.119.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 11 Feb 2004 19:22:21 -0800, john stultz <johnstul@us.ibm.com> said:

  John> All, This patch provides access to the cyclone time source
  John> found on IBM EXA based systems (x450 and x455). This is needed
  John> on multi-node systems where the CPU ITCs are not synchronized,
  John> causing possible time inconsistencies.

  John> I tried my best to properly follow the time_interpolator
  John> interface, but please let me know if you see any mistakes.

  John> Any comments or suggestions would be greatly appreciated.

It looks mostly OK to me.  Some comments:

 - It seems to me cyclone.c should check whether the SAL ITCdrift flag
   is on and register the cyclone time-interpolator only if it is
   turned on.

 - When accessing iomemory space, please use readX()/writeX().  For
   example:

 +	offset = cyclone_timer[0];

   should be:

	offset = readl (cyclone_timer);

 - The formatting is a bit weird.  You can format it for 100 columns
   wide and it would be nice if you could drop all the trailing
   whitespace.

 - This:
+	u32 offset;
	  [snip]
+	offset = (offset*NSEC_PER_SEC)/CYCLONE_TIMER_FREQ;
   will overflow in about 4.3 seconds.  Not likely to happen but
   it might be safer to declare "offset" as "u64".

	--david
