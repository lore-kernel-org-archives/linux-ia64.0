From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Jan 2005 01:54:40 +0000
Subject: Re: anyone using Itanium B-step support?
Message-Id: <16889.39776.919220.660326@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
In-Reply-To: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Jan 2005 17:24:02 -0800, James E Wilson <wilson@tuliptree.org> said:

  James> On Thu, 2005-01-27 at 13:56, James E Wilson wrote:
  >> However, rather than add more ITANIUM_BSTEP_SPECIFIC support to
  >> the kernel, I think it makes more sense to obsolete it and remove
  >> it.

  James> Here is the change I am suggesting.

Looks fine to me.  I found one more reference to
CONFIG_ITANIUM_BSTEP_SPECIFIC in arch/ia64/configs/bigsur_defconfig.
Not that it really matters, but from a cleanliness perspective, we may
want to get rid of that at the same time.

I would have done it myself but there was no "Signed-off-by" trailer
in your patch so I think you may need to resend the patch anyhow
before Tony will take it (unless he judges the patch to be trivial
enough not to need this).

	--david
