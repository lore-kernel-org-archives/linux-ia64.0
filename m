From: Horms <horms@verge.net.au>
Date: Wed, 12 Jul 2006 04:45:05 +0000
Subject: Re: cross compiling for ia64?
Message-Id: <20060712044505.639F834047@koto.vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <CFF307C98FEABE47A452B27C06B85BB6E59456@hdsmsx411.amr.corp.intel.com>
In-Reply-To: <CFF307C98FEABE47A452B27C06B85BB6E59456@hdsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 6 Jul 2006 13:30:32 +1000, Ian Wienand wrote:
> 
> --GvXjxJ+pjyke8COw
> Content-Type: text/plain; charset=us-ascii
> Content-Disposition: inline
> 
> On Wed, Jul 05, 2006 at 10:43:48PM -0400, Brown, Len wrote:
>> Does anybody have the latest instructions and tools to
>> cross compile to ia64 from i386 or x86_64 hosts?
> 
> What distribution are you using?
> 
> The generic way is http://www.kegel.com/crosstool/ though I tend to
> have varying levels of success with that.

I can confirm that crosstool works very well for me here (on Debian
unstable). I'm using crosstool-0.42 and I use gcc-3.4.5-glibc-2.3.6.dat,
which I updated to use binutils-2.16.91.0.7, as that is needed for xen
(though I forget specifically why, other than that the build falls
over).

-- 
Horms                                           
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

