From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 06 Jan 2004 16:52:45 +0000
Subject: Re: [PATCH] first stab at generic_defconfig
Message-Id: <20040106165245.GA24246@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040106012537.GA21877@sgi.com>
In-Reply-To: <20040106012537.GA21877@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 06, 2004 at 08:40:31AM -0700, Alex Williamson wrote:
> On Mon, 2004-01-05 at 18:29, Jesse Barnes wrote:
> 
> > Well, here's one that disables some of the block devices I had turned
> > on.  I've noticed that some of the other arches try to enable everything
> > as a module even if it's not particularly relevant, but maybe we should
> > do the same?
> 
>    I favor enabling too much, especially USB type things.  As long as
> they can be built as modules.  probably ought to take a broad sampling
> of SCSI and NICs as well.  Here's a patch that adds some essential

Ok, that sounds good.

> drivers for HP systems and a couple extras.  BTW, the removal of
> CONFIG_BLK_DEV_SGIIOC4 was not intentional.  According to a new pull of
> linux-ia64-2.5, it depends on IA64_SGI_SN2.  Should that be ||
> IA64_GENERIC?  Thanks,

I already sent a patch to Andrew to fix that.  I just removed the
depends altogether.

Thanks,
Jesse
