From: Simon Horman <horms@verge.net.au>
Date: Wed, 08 Oct 2008 22:09:23 +0000
Subject: Re: [patch] ia64: Order of operations bug in PT_LOAD segment reader
Message-Id: <20081008220922.GI16178@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081008064940.GA11893@verge.net.au>
	<jeljwza5a6.fsf@sykes.suse.de>
In-Reply-To: <jeljwza5a6.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Schwab <schwab@suse.de>
Cc: kexec@lists.infradead.org, Bernhard Walle <bwalle@suse.de>, "Luck,
	Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Jay Lan <jlan@sgi.com>

On Wed, Oct 08, 2008 at 09:56:49AM +0200, Andreas Schwab wrote:
> Simon Horman <horms@verge.net.au> writes:
> 
> > The bug comes about because the break statment was never executed because
> > the if clause would bever be true because the if clause will never be true
> > because &  has higher precedence than !=.
>                  ^^^^^^
>                  lower

Thanks.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

