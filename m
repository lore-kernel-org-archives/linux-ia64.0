From: Anton Blanchard <anton@samba.org>
Date: Wed, 24 Mar 2004 01:49:56 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <20040324014956.GG27747@krispykreme>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 
> yes, perhaps it's not too late to change it.  Anton, what will this break?

pci_dma_error came from x86-64, and dma_error was the natural
counterpart. Due to the conflicts in ide-cd.c I guess we should change
it.

Anton
