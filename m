From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Mar 2007 19:22:02 +0000
Subject: Re: [PATCH] - Speed up boot - skip unnecessary clock calibration
Message-Id: <20070327192202.GA29785@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327132953.GA14401@sgi.com>
In-Reply-To: <20070327132953.GA14401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 27, 2007 at 12:17:17PM -0700, Yu, Fenghua wrote:
> >+	 */
> >+	if (local_cpu_data->itc_freq != per_cpu(cpu_info, cpuid -
> 1).itc_freq >||
> >+			local_cpu_data->proc_freq != per_cpu(cpu_info,
> cpuid - >1).proc_freq ||
> 
> BSP (cupid=0) should always calibrate delay. Otherwise the patch won't
> work.

True, but the call to calibrate the delay on cpu 0 comes from a different
place. See the call in init/main.c.

The code in smp_callin() is only called for cpus 1, 2, ...


-- jack
