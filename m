From: Dinakar Guniguntala <dino@in.ibm.com>
Date: Mon, 22 Aug 2005 20:28:26 +0000
Subject: Re: [PATCH] ia64 cpuset + build_sched_domains() mangles structures
Message-Id: <20050822201626.GC7686@in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <43074328.MailOXV1UXUHF@jackhammer.engr.sgi.com> <20050822070834.GA16722@elte.hu> <20050822141414.GB7686@in.ibm.com> <20050822160719.GB6652@elte.hu>
In-Reply-To: <20050822160719.GB6652@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: John Hawkes <hawkes@jackhammer.engr.sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, pj@sgi.com, nickpiggin@yahoo.com.au, akpm@osdl.org

On Mon, Aug 22, 2005 at 06:07:19PM +0200, Ingo Molnar wrote:
> great! Andrew, i'd suggest we try the merged patch attached below in 
> -mm.
> 

Ingo, unfortunately I am hitting panic's on stress testing. The panic
screen is attached in the .png below.

On debugging I found that the panic happens consistently in this line
 of code in function find_busiest_group

	*imbalance = min((max_load - avg_load) * busiest->cpu_power,
                                (avg_load - this_load) * this->cpu_power)
                        / SCHED_LOAD_SCALE;

Here I find that the "this" pointer is still NULL. I verified this by
a quick hack as below in the same function and with this hack it seems 
to run for hours

-	if (!busiest || this_load >= max_load)
+	if (!this || !busiest || this_load >= max_load)

This can only happen if the none of the sched groups pointed to by the 
'sd' of the current cpu contain the current cpu. I was wondering if
this had anything to do with the way that we are using RCU to assign/
read the 'sd' pointer.

Any thoughts ??

	-Dinakar

