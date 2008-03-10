From: Russ Anderson <rja@sgi.com>
Date: Mon, 10 Mar 2008 21:10:31 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <20080310211030.GB8678@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 06, 2008 at 11:24:06AM +0100, Zoltan Menyhart wrote:
> Russ Anderson wrote:
> 
> >I have a test case that creates that scenario.  With your patch and only 
> >one of the MCAs (at most) end up getting logged in 
> >/var/log/salinfo/decoded .
> 
> Can you describe, please, what your test does and what is the
> expected behavior of the MCA layer?

The test process allocates memory, injects an uncorrectable error, 
forks a child, then both processes consume the bad data, with
the effect of two processes going into OS_MCA at the same time.

With the old code a total of four MCA records get logged.  
(Overkill, an opportunity for improvement.)  Each cpu that went 
through MCA logs the error twice, with one of the records being
marked recovered (each pair of records are otherwise identical). 

With the new code the first MCA is reported as occuring on cpu 0
when it occured on cpu 1.  I think it is due to this code in
arch/ia64/kernel/salinfo.c:

-------------------------------------------------------------
        n = data->cpu_check;
//      printk("CPU %d: %s(): data->cpu_check: %d, data->cpu_event: %016lx\n", smp_processor_id(),
//                                      __func__, n, data->cpu_event.bits[0]);  // :-)
        if (atomic_read(&ia64_MCA_logs._b_cnt) > 0 || atomic_read(&ia64_INIT_logs._b_cnt) >
 0){
//              printk("cpu %d %d %d\n", cpu, atomic_read(&ia64_MCA_logs._b_cnt), atomic_read(&ia64_INIT_logs._b_cnt));
                cpu = any_online_cpu(cpu_online_map);
        } else {
                for (i = 0; i < NR_CPUS; i++) {
                        if (cpu_isset(n, data->cpu_event)) {
                                if (!cpu_online(n)) {
                                        cpu_clear(n, data->cpu_event);
                                        continue;
                                }
                                cpu = n;
                                break;
                        }
                        if (++n = NR_CPUS)
                                n = 0;
                }

                if (cpu = -1)
                        goto retry;

                ia64_mlogbuf_dump();

                /* for next read, start checking at next CPU */
                data->cpu_check = cpu;
                if (++data->cpu_check = NR_CPUS)
                        data->cpu_check = 0;
        }
        snprintf(cmd, sizeof(cmd), "read %d\n", cpu);  
-------------------------------------------------------------
This line
                cpu = any_online_cpu(cpu_online_map);

returns 0, so the MCA gets marked as being on cpu 0 instead
of the actual cpu (cpu 1).

 
> Another idea: the integration into the salinfo side in not yet quit smooth, 
> :-)

Understood.

> it is the polling that fetches the logs one by one. Please leave 3 periods
> for the polling to see all the logs.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
