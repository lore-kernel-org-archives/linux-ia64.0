From: root <davidm@hpl.hp.com>
Date: Tue, 12 Jun 2001 17:52:57 +0000
Subject: Re: [Linux-ia64] IO/TLB bounce buffer space
Message-Id: <marc-linux-ia64-105590693005720@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005716@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005716@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 12 Jun 2001 19:01:10 +0200 (CEST), Martin Wilck <Martin.Wilck@fujitsu-siemens.com> said:

  Martin> I guess it will be necessary to use both lower SCB numbers
  Martin> in the aic7xxx driver and increase IO-TLB space.  All of
  Martin> this can already be done with kernel command line options,
  Martin> but will be quite cumbersome to figure out (and tune right)
  Martin> for administrators.

Yes, that's certainly not ideal.  A machine should boot without
requiring any tuning-type command-line options.

  Martin> There will always be some danger of IO-TLB overflow,
  Martin> however, unless a way is found to gracefully abort an
  Martin> operation if the IO-TLB space is full (or unless all
  Martin> hardware vendors make their boards 64-bit capable).

There isn't.  Dave Miller blames me for not bringing up this issue
early enough when the PCI DMA interface was designed.  Not that it
would have made much of a difference: it's difficult to recover
gracefully in interrupt handlers, especially considering how many
drivers are our there that would have to be updated for this...

We can either try to improve the heuristic that guesses the right
static size of the I/O TLB buffers or we can make it more dynamic by
using atomic allocations.  Either way, it looks to me like the aic7xxx
driver should be tuned to not generate so many concurrent requests.

  Martin> Btw: will _hardware_ IO-TLB support be available some time
  Martin> soon?  (I figure that's what's being done on Alpha, right?)

As soon as there are chipsets that support it!

That's not going to happen for Itanium.  For McKinley, we just have to
wait and see...

	--david

