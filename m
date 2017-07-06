From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Thu, 06 Jul 2017 09:45:26 +0000
Subject: Re: [PATCH 2/7] rwsem-spinlock: Add killable versions of rwsem_down_read_failed()
Message-Id: <edcdffb3-f9f3-cfcf-43c8-ca854e011010@virtuozzo.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
 <149789534632.9059.2901382369609922565.stgit@localhost.localdomain>
 <20170706080447.a7emouoysilqex4p@hirez.programming.kicks-ass.net>
In-Reply-To: <20170706080447.a7emouoysilqex4p@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net

On 06.07.2017 11:04, Peter Zijlstra wrote:
> On Mon, Jun 19, 2017 at 09:02:26PM +0300, Kirill Tkhai wrote:
> 
>> Subject: [PATCH 2/7] rwsem-spinlock: Add killable versions of rwsem_down_read_failed()
> 
>>  kernel/locking/rwsem-xadd.c |   33 ++++++++++++++++++++++++++++++---
> 
> Fixed that subject for your ;-)

Thanks :)
