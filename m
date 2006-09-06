From: Arjan van de Ven <arjan@infradead.org>
Date: Wed, 06 Sep 2006 19:06:19 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <1157569579.29093.51.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org>
	 <Pine.LNX.4.64.0609061120430.27779@g5.osdl.org>
	 <20060906182733.GJ2558@parisc-linux.org>
In-Reply-To: <20060906182733.GJ2558@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linus Torvalds <torvalds@osdl.org>, Kirill Korotaev <dev@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org

On Wed, 2006-09-06 at 12:27 -0600, Matthew Wilcox wrote:
> On Wed, Sep 06, 2006 at 11:24:05AM -0700, Linus Torvalds wrote:
> > If MIPS and parisc don't matter for the stable tree (very possible - there 
> > are no big commercial distributions for them), then dammit, neither should 
> > ia64 and sparc (there are no big commercial distros for them either). 
> 
> Erm, RHEL and SLES both support ia64.

but neither use -stable.


