From: "John Hawkes" <hawkes@sgi.com>
Date: Wed, 24 Aug 2005 00:19:07 +0000
Subject: Re: [PATCH 2.6.13-rc6] cpu_exclusive sched domains on partial nodes temp fix
Message-Id: <01de01c5a841$71ed60d0$6900a8c0@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050823080427.14740.20177.sendpatchset@jackhammer.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, mingo@elte.hu, Paul Jackson <pj@sgi.com>, dino@in.ibm.com

> + for_each_cpu_mask(i, cur->cpus_allowed) {
> + for_each_cpu_mask(j, node_to_cpumask(cpu_to_node(i))) {
> + if (!cpu_isset(j, cur->cpus_allowed))
> + return;

Looks good to me.
Feel free to add:
Acked-by: John Hawkes <hawkes@sgi.com>


John Hawkes

