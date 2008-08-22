From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 22 Aug 2008 00:23:46 +0000
Subject: RE: linux-next: ia64 allmodconfig
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309EDDDFE@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080820233526.14c44ea6.akpm@linux-foundation.org>
In-Reply-To: <20080820233526.14c44ea6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The resulting binary should be faster, though. ;-)

Ah, but I spend much more time compiling kernels than I do
running them ... so this isn't a good tradeoff for me ;-)

> How about giving
> GCC 4.3 a try, by the way?  IIRC, GCC 4.2 has some aliasing issues
> that have been addressed.

I tried 4.3.1 and got:

configure: error: Building GCC requires GMP 4.1+ and MPFR 2.3.0+.

So I'll have to do some other upgrading and installing on my
ancient build box to make this work :-(

-Tony
