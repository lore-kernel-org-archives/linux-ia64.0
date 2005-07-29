From: Matt Chapman <matthewc@hp.com>
Date: Fri, 29 Jul 2005 23:33:58 +0000
Subject: Re: __copy_user exception handling
Message-Id: <20050729233358.GA32341@kirby.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050729221044.GA23144@kirby.fc.hp.com>
In-Reply-To: <20050729221044.GA23144@kirby.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 29, 2005 at 04:23:33PM -0700, Chen, Kenneth W wrote:
> 
> Because exception handler use to work at instruction bundle granularity.
> The first EX would automatically catch the 2nd ld8 or st8, with a caveat
> that this code is assuming gcc 2.x tool chain.  With moving to gcc 3.x
> assembler where it understand local tag support, the exception handler
> works at instruction granularity and then all the sudden, it falls flat
> on its face.

Ah right.

> Are you sure you want to use this code?  It's for first incarnation of
> Itanium.  The kernel has an optimized version of copy_user for Itanium2.
> See memcpy_mck.S

Aha, thank you!  That explains why I can't trigger that bug in Linux
on Itanium 2.  I'll make Xen use the memcpy_mck.S version.

Matt
