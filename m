From: Simon Horman <horms@verge.net.au>
Date: Thu, 02 Oct 2008 05:13:50 +0000
Subject: Re: kdump broken on Altix 350
Message-Id: <20081002051348.GA1027@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA34DB4172D@orsmsx505.amr.corp.intel.com>
	<200809292342.m8TNgq4u004680@agluck-lia64.sc.intel.com>
In-Reply-To: <200809292342.m8TNgq4u004680@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Jay Lan <jlan@sgi.com>, Bernhard Walle <bwalle@suse.de>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>

On Mon, Sep 29, 2008 at 04:42:52PM -0700, Luck, Tony wrote:
> Does this make kexec/kdump happier?  Bare minimum testing so far
> (builds and boots on tiger ... didn't try kexec yet).

Hi Tony,

your analysis (in your previous email) was more or less the same
conclusion that I had come too, though I was puzzling over
why you had put the reserved area for cpu0 where you had - I assumed
I was misunderstanding things.

This patch looks good to me.

Jay,

With this patch I assume that we still need an order of operations fix for
kexec-tools but no section merging changes. Is that correct?

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

