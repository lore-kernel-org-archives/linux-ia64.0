From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 30 Jun 2004 16:17:18 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406300917.18794.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, June 29, 2004 4:18 pm, David Mosberger wrote:
> >>>>> On Tue, 29 Jun 2004 11:19:34 -0700, "Chen, Kenneth W"
> >>>>> <kenneth.w.chen@intel.com> said:
>
>   Ken> Looks like there are more places where kernel does "virt ->
>   Ken> phys -> virt".  And conversion from phys to virt is setting 3
>   Ken> msb to 1.
>
> Your fixes work fine on the machines I have tried so far (variety of
> Itanium 2 boxen and a Big Sur Merced box).
>
> Jesse, do you know if unapplying the "move current to region 5" patch
> fixes your boot-problem?  For convenience, I attached the (original)
> patch below.

Yes, reverting that patch does fix the hang I'm seeing.

Jesse
