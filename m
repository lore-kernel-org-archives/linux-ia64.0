From: Grant Grundler <iod00d@hp.com>
Date: Wed, 03 Sep 2003 22:10:34 +0000
Subject: Re: [patch] platform hook for timer_interrupt()
Message-Id: <marc-linux-ia64-106262716804346@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106261055215953@msgid-missing>
In-Reply-To: <marc-linux-ia64-106261055215953@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 03, 2003 at 07:49:18PM +0100, Matthew Wilcox wrote:
> How about smp_call_function() in a regular timer then?

smp_call_function() is kind of messy since it uses IPI to call
on each CPU. Not sure that's a good solution since it won't complete
until all the CPUs have executed the given function.
If kernel threads or tasklets don't cut it, I could understand why
using a timers machvec would be "lighter weight".

grant
