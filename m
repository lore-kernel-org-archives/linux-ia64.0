From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 23 Sep 2005 07:10:08 +0000
Subject: Re: Using Cpusets with HyperThreads
Message-Id: <12177.1127459408@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050923000016.2cc416ac.pj@sgi.com>
In-Reply-To: <20050923000016.2cc416ac.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 23 Sep 2005 00:00:16 -0700, 
Paul Jackson <pj@sgi.com> wrote:
>	cpus 0-127:2    # the even numbered CPUs 0, 2, 4, ... 126
>	mems 0-63       # all memory nodes 0, 1, 2, ... 63
>
>   would include the A sides of an HT enabled system, along with
>   all the memory, on the first 64 nodes. The colon ':' prefixes the
>   stride. The stride of '2' in this example means use every other
>   logical CPU.

I prefer the cron usage for striding, 0-127/2 or even */2.

