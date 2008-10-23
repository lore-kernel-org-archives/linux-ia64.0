From: Robin Holt <holt@sgi.com>
Date: Thu, 23 Oct 2008 14:12:32 +0000
Subject: Re: [PATCH 0/2] enable irqs when waiting for rwlocks
Message-Id: <20081023141232.GC8483@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224664414.4430.33.camel@elijah.suse.cz> <48FF6389.9050408@hp.com>
In-Reply-To: <48FF6389.9050408@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rick Jones <rick.jones2@hp.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tee@sgi.com

On Wed, Oct 22, 2008 at 10:31:53AM -0700, Rick Jones wrote:
> Petr Tesarik wrote:
>> Hello,
>>
>> SGI has observed that on large systems, interrupts are not serviced for
>> a long period of time when waiting for a rwlock. The following patch
>> series re-enables irqs while waiting for the lock, resembling the code
>> which is already there for spinlocks.
>
> Perhaps I'm just out in left field, but that (and the similar behaviour  
> for obtaining a spinlock?) feels like treating a symptom rather than a  
> root cause where the root cause would appear to be long lock hold  
> times/contention?

Sometimes lock contention on large systems will take a few seconds to
pass.  This is normal behavior which simply can not be eliminated.  For
those cases, we need to rely upon being able to re-enable interrupts and
allowing other operations to continue normally.  Simply put, in some
cases, nothing more can be done.

Thanks,
Robin
