From: Kyle McMartin <kyle@mcmartin.ca>
Date: Thu, 25 May 2006 01:07:05 +0000
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <20060525010705.GA7024@skunkworks.cabal.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 24, 2006 at 02:23:18PM -0700, Luck, Tony wrote:
> 
> The alternative to dropping support for CONFIG_IA32_SUPPORT is
> to find someone to maintain it ... right now it doesn't get much
> of my time, so it is a ticking quagmire of untested code.
>

I'll give it some love. I've got an old BigSur proto and a rx5670 running
Debian so it shouldn't be very hard to keep an i386 chroot tested.

That and I already pay attention to syscall additions when I update
the parisc syscall table. 

Cheers,
	Kyle
