From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 22 Sep 2003 23:21:14 +0000
Subject: Re: adilger_irq patch
Message-Id: <marc-linux-ia64-106427289505563@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106426969402495@msgid-missing>
In-Reply-To: <marc-linux-ia64-106426969402495@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 22 Sep 2003 16:21:14 -0600, Andreas Dilger <adilger@clusterfs.com> said:

  Andreas> Hi, below is a patch that we have been running on ia64 for
  Andreas> several months now.  It makes the IRQ stack overflow
  Andreas> checking a bit more robust, and also adds a config option
  Andreas> to be consistent with i386.

  Andreas> One important change is that stack overflow messages to the
  Andreas> console are rate limited, because without it if you ever
  Andreas> hit this your console will continually spew messages as the
  Andreas> console output is slower than the IRQ rate and you will
  Andreas> continue to be over the stack limit forever.  This causes
  Andreas> the machine to effectively lock up without the rate
  Andreas> limiting.

Well, there already _was_ rate-limiting code.  Are you saying that the
rate is too high (i.e., your console is so slow that it cannot sustain
an average rate of 1 warning message per second)?  If so, I suppose
you could reduce the rate to something lower.  But you might also want
to consider configuring your console for higher speed (with the HP
firmware, you can use the "baud" EFI command).

  Andreas> The stack overflow margin is increased slightly for larger
  Andreas> stack sizes, because we probably shouldn't be getting so
  Andreas> close to the end of a larger 64kB stack either.  Not really
  Andreas> critical, we never run with 64kB stacks.

-		if ((sp - bsp) < 1024) {
+		if (unlikely((sp - bsp) <
+			     1024 + (IA64_STK_OFFSET > 32768 ? 8192 : 0))) {

This doesn't make any sense to me.  Why should the safety-margin be
bigger for larger stack sizes?  I can see why you might want more than
1KB, but I don't think this minimum should dependend on the max. stack
size.

Given this:

+				show_stack(0);

you _definitely_ want to set the minimum >1KByte.  Note that show_stack()
calls unw_init_running(), which allocates ~1KByte all by itself.

	--david
