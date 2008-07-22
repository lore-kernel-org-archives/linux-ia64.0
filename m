From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 22 Jul 2008 11:36:46 +0000
Subject: Re: [PATCH] Make u64 long long on all architectures (was: the
Message-Id: <1216726606.11027.207.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com>
	 <20080704104634.GA31634@digi.com>
	 <20080704111540.ddffd241.akpm@linux-foundation.org>
	 <alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	 <alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
	 <20080704132716.f1e12554.akpm@linux-foundation.org>
	 <20080704204252.GM14894@parisc-linux.org>
	 <20080704150100.1f7b8a65.akpm@linux-foundation.org>
	 <20080705020350.GN14894@parisc-linux.org>
	 <20080722030506.206a2cc2.akpm@linux-foundation.org>
	 <1216722995.8357.4.camel@localhost>
In-Reply-To: <1216722995.8357.4.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: michael@ellerman.id.au
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

On Tue, 2008-07-22 at 20:36 +1000, Michael Ellerman wrote:
> concordia powerpc(master) $ find arch/powerpc/ ! -name '*32.*' | xargs
> grep "%l" | grep -v "%ll" | wc -l
> 635
> 
> 
> Someone's gonna get a lot of git points for fixing all those. Might
> keep
> the speeling fix crowd busy for a 

But a bunch of those might actually be real longs, not u64's ...

Easier to do the change and build something like ppc6xx_defconfig to get
a better approximation.

Ben.


