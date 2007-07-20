From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 20 Jul 2007 19:06:48 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <alpine.LFD.0.999.0707201206130.27249@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Fri, 20 Jul 2007, Luck, Tony wrote:
> 
> This will update the files shown below.  I'm touching a few
> non-ia64 files (they are at the bottom of the diffstat) in here
> to delete the CONFIG_TIME_INTERPOLATION code that nobody except
> ia64 used.

Thanks. That timekeeping duplication was confusing.

		Linus
