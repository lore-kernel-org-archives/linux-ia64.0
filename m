From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 06 Feb 2008 02:23:57 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <47A91A3D.3070708@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote:
> On Wed, Feb 06, 2008 at 09:30:17AM +0900, Hidetoshi Seto wrote:
>> Russ Anderson wrote:
>>> The MCA code allocates bootmem memory for NR_CPUS, regardless
>>> of how many cpus the system actually has.
>> So... how about using num_possible_cpus() instead?
> 
> num_possible_cpus() is not initialized until after this code is run for
> the first time.

I grant you.
Then, I suppose we need a CPU_UP_PREPARE callback to allocate memory
before hot-added CPU enters cpu_init().

Thanks,
H.Seto

