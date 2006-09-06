From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 06 Sep 2006 18:27:33 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <20060906182733.GJ2558@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org> <Pine.LNX.4.64.0609061120430.27779@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0609061120430.27779@g5.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Kirill Korotaev <dev@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org

On Wed, Sep 06, 2006 at 11:24:05AM -0700, Linus Torvalds wrote:
> If MIPS and parisc don't matter for the stable tree (very possible - there 
> are no big commercial distributions for them), then dammit, neither should 
> ia64 and sparc (there are no big commercial distros for them either). 

Erm, RHEL and SLES both support ia64.
