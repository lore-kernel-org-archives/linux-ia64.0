From: Grant Grundler <iod00d@hp.com>
Date: Tue, 24 Feb 2004 01:54:52 +0000
Subject: Re: Oops in pdflush
Message-Id: <20040224015452.GL26488@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 20, 2004 at 02:34:03PM +0100, Andreas Schwab wrote:
> This happens regularily on all our Intel Tiger SMP systems, haven't seen
> it on UP systems, and neither on any HP system we have.  Theses oopses are
> all from different systems running kernels 2.6.2 and 2.6.3 in various
> incarnations.  They are all using e1000 and mptscsih, unlike the HP
> systems, so it might be a bug in either of those drivers.

I have been running e1000 (and tg3) drivers locally quite a bit
the past couple of monthes.
rx2000 uses e1000 for built-in GigE NIC.

rx2600, zx6000, and a few other machines use LSI 53c1030 chip
(MPT/Fusion driver) on the motherboard. My rx2600 seems to be
happy with 2.6.3-rc2 though I've not run any disk IO stress
tests on it lately.

hth,
grant
