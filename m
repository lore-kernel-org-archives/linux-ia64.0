From: Grant Grundler <iod00d@hp.com>
Date: Tue, 13 Jan 2004 01:00:59 +0000
Subject: Re: old tulip patch
Message-Id: <20040113010059.GB16053@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401130013.i0D0D2F6012444@napali.hpl.hp.com>
In-Reply-To: <200401130013.i0D0D2F6012444@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 12, 2004 at 04:13:02PM -0800, David Mosberger wrote:
> I'd like to remove the attached old patch from my linux-ia64-2.5 tree.
> If anybody thinks it's still needed, please speak up now.

Sorry - that's my mess. Feel free to remove it.
I expect tulip will stop working for some folks.

Turns out that while the simple udelay() usually works, the driver
ignores the 802.3 spec.  Newer patch is here:
	ftp://ftp.parisc-linux.org/patches/diff-tulip_phy_reset-03

Jeff Garzik rejected this patch because it introduces a potential
1ms delay while holding off interrupts. I agree this is not a good
thing. But it's better than not working.

Jeff wanted me to avoid this by adding schedule_timeout() to the code
path someplace. I refused since the above Works For Me and the init
sequence in tulip is, uhm, well, "difficult". It covers too many
different NICs for me to even begin to understand all the variations.
I felt my patch was fairly low risk change to a "mature" product.

I'll maintain the patch for SuSE/RHAS/Debian on ia64 and for parisc-linux.

thanks,
grant
