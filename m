From: Grant Grundler <iod00d@hp.com>
Date: Wed, 25 Aug 2004 17:09:01 +0000
Subject: Re: [RFC&PATCH 2/2] PCI Error Recovery (readX_check)
Message-Id: <20040825170901.GD19447@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <412AD1EA.6080306@jp.fujitsu.com>
In-Reply-To: <412AD1EA.6080306@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>

On Tue, Aug 24, 2004 at 02:28:10PM +0900, Hidetoshi Seto wrote:
> +	bool "PCI device error recovery"
> +	depends on PCI

	depends on PCI && EXPERIMENTAL

> +	---help---
> +	By default, the device driver hardly recovers from PCI errors. When
> +	this feature is available, the special io interface are provided
> +	from the kernel.

May I suggest an alternate text?
	Saying Y provides PCI infrastructure to recover from some PCI errors.
	Currently, very few PCI drivers actually implement this.
	See Documentation/pci-errors.txt for a description of the
	infrastructure provided.

I'm still digesting the rest of the patch.

grant
