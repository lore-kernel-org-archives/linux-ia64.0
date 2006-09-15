From: Keith Owens <kaos@sgi.com>
Date: Fri, 15 Sep 2006 07:27:10 +0000
Subject: Re: [Fastboot] [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
Message-Id: <478.1158305230@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
In-Reply-To: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Takao Indoh (on Fri, 15 Sep 2006 14:34:16 +0900) wrote:
>I have one question. When one cpu sends IPI and other cpus receive INIT
>interrupt, which cpus become monarch? Is there possibility that all cpus
>which receive INIT become slave cpu? If so, these cpus must wait until
>monarch cpu comes. 
>
>        if (!sos->monarch) {
>                ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_INIT;
>                while (monarch_cpu = -1)
>                       cpu_relax();     /* spin until monarch enters */
>
>It means these cpus enter infinite loop because the remaining one cpu
>never comes to ia64_init_handler.

Correct, and it does happen.  KDB has already solved this problem, the
monarch cpu is the one that started the debug[*] process, all the other
cpus have to be treated as slaves, whether they are interrupted by IPI
or NMI/INIT.  It gets complicated by broken proms that treat some INIT
events as monarch when they are really slaves.

I am back from vacation and am now working on a common 'crash stop'
synchronization interface that can be used by all the debug[*] tools,
instead of everybody inventing their own and tripping over each other.
Obviously it is based on the KDB patch, but it will be generic enough
that anybody can use it.

[*] Using the term 'debug' generically here.  It can be a debugger like
    kdb, kgdb, nlkd or a crash dump tool like lkcd, crash or kexec.
    They all have the same synchronization requirements, stop all cpus
    using NMI/INIT where necessary and save the state of all the cpus
    for later diagnosis.

