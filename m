From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Jan 2004 01:09:03 +0000
Subject: Re: old tulip patch
Message-Id: <16387.17711.667314.728494@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401130013.i0D0D2F6012444@napali.hpl.hp.com>
In-Reply-To: <200401130013.i0D0D2F6012444@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'll drop it from my tree then and let you and Jeff figure out what to
do about it.

Thanks,

	--david

>>>>> On Mon, 12 Jan 2004 17:00:59 -0800, Grant Grundler <iod00d@hp.com> said:

  Grant> On Mon, Jan 12, 2004 at 04:13:02PM -0800, David Mosberger wrote:
  >> I'd like to remove the attached old patch from my linux-ia64-2.5 tree.
  >> If anybody thinks it's still needed, please speak up now.

  Grant> Sorry - that's my mess. Feel free to remove it.
  Grant> I expect tulip will stop working for some folks.

  Grant> Turns out that while the simple udelay() usually works, the driver
  Grant> ignores the 802.3 spec.  Newer patch is here:
  Grant> ftp://ftp.parisc-linux.org/patches/diff-tulip_phy_reset-03

  Grant> Jeff Garzik rejected this patch because it introduces a potential
  Grant> 1ms delay while holding off interrupts. I agree this is not a good
  Grant> thing. But it's better than not working.

  Grant> Jeff wanted me to avoid this by adding schedule_timeout() to the code
  Grant> path someplace. I refused since the above Works For Me and the init
  Grant> sequence in tulip is, uhm, well, "difficult". It covers too many
  Grant> different NICs for me to even begin to understand all the variations.
  Grant> I felt my patch was fairly low risk change to a "mature" product.

  Grant> I'll maintain the patch for SuSE/RHAS/Debian on ia64 and for parisc-linux.

  Grant> thanks,
  Grant> grant
