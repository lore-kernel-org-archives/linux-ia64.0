From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 23 Sep 2005 17:26:27 +0000
Subject: RE: Using Cpusets with HyperThreads
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04795D9C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050923000016.2cc416ac.pj@sgi.com>
In-Reply-To: <20050923000016.2cc416ac.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
>On Fri, 23 Sep 2005 00:00:16 -0700, 
>Paul Jackson <pj@sgi.com> wrote:
>>	cpus 0-127:2    # the even numbered CPUs 0, 2, 4, ... 126
>>	mems 0-63       # all memory nodes 0, 1, 2, ... 63
>>
>>   would include the A sides of an HT enabled system, along with
>>   all the memory, on the first 64 nodes. The colon ':' prefixes the
>>   stride. The stride of '2' in this example means use every other
>>   logical CPU.
>
>I prefer the cron usage for striding, 0-127/2 or even */2.

Perhaps it would be better to avoid all assumptions that even
cpu numbers correspond to "side A" and odd to "side B" and just
provide a syntax that allows you to pick some subset of cores
or threads from a range of sockets and get people used to something
like:

  cpus S(0-15).t=0

to mean get the cpu numbers of all the thread zeros in any cores in
sockets 0-15.

-Tony
