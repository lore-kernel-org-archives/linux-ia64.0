From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 25 Jul 2003 13:40:07 +0000
Subject: Re: [PATCH] don't use ld.bias
Message-Id: <marc-linux-ia64-105914052618360@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883179830025@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883179830025@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 24, 2003 at 06:10:13PM -0700, David Mosberger wrote:
> >>>>> On Mon, 21 Jul 2003 16:55:59 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> Patch to fix spin_lock to not use ld.bias since it causes a
>   Jesse> bunch of bus activity that hurts scalability when a lock is
>   Jesse> contended.
> 
> Yes, using ld.bias really was wrong there.  However, instead of
> applying your patch, I dropped the old lock code (which was
> effectively dead code) and instead removed the .bias from the
> ia64_spinlock_contention() routine in head.S.

Even better.  Thanks.

Jesse
