From: James E Wilson <wilson@tuliptree.org>
Date: Fri, 28 Jan 2005 02:32:49 +0000
Subject: Re: anyone using Itanium B-step support?
Message-Id: <1106879568.18514.158.camel@aretha.corp.specifixinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
In-Reply-To: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-01-27 at 17:54, David Mosberger wrote:
> Looks fine to me.  I found one more reference to
> CONFIG_ITANIUM_BSTEP_SPECIFIC in arch/ia64/configs/bigsur_defconfig.

I see no such file in my copy of linux-2.6.8.1 downloaded from
kernels.org, but yes, that should be fixed too.

> I would have done it myself but there was no "Signed-off-by" trailer
> in your patch so I think you may need to resend the patch anyhow

I know nothing about submitting linux kernel patches.  My patch is
completely untested, by the way, as I doubt that I can build a working
kernel without help.  It was more a suggestion than an actual patch.

