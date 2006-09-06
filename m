From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 06 Sep 2006 19:17:40 +0000
Subject: Re: [stable] [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <Pine.LNX.4.64.0609061214430.11553@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org> <Pine.LNX.4.64.0609061120430.27779@g5.osdl.org>
 <20060906182733.GJ2558@parisc-linux.org> <20060906184509.GA15942@kroah.com>
 <20060906191215.GK2558@parisc-linux.org>
In-Reply-To: <20060906191215.GK2558@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Greg KH <greg@kroah.com>, Linus Torvalds <torvalds@osdl.org>, Kirill Korotaev <dev@openvz.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org, Fernando Vazquez <fernando@oss.ntt.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable@kernel.org, "David S. Miller" <davem@davemloft.net>, devel@openvz.org, xemul@openvz.org

On Wed, 6 Sep 2006, Matthew Wilcox wrote:

> What's the easiest way to get coverage here?  Sending a parisc
> workstation or server to someone?  Giving accounts to some/all of the
> stable team?  Finding someone who cares about parisc to join the stable
> team?

Follow the conventional patch: Send patch to Andrew for mm inclusion so 
that we can all test it and then get it into Linus' tree?

2.6.17.x is used neither by Suse nor by Redhat. For Suse exposure you may 
have to get it into 2.6.16.x.

