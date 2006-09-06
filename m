From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 06 Sep 2006 21:27:54 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <20060906212754.GA3222@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org> <Pine.LNX.4.64.0609061314430.27779@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0609061314430.27779@g5.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Kirill Korotaev <dev@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org

On Wed, Sep 06, 2006 at 01:20:59PM -0700, Linus Torvalds wrote:
> Btw, is there some reason for the __ASSEMBLY__ check?

On ia64 entry.S includes asm/pgtable.h, which includes asm/mman.h

-Tony
