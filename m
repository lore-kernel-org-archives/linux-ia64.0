From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Mon, 09 Jan 2006 17:41:03 +0000
Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <200601091741.k09Hf4gI477712@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E840469321C@pdsmsx404> from "Zhang, Yanmin" at Jan 09, 2006 02:35:36 PM
References: <20051220180929.B19129@unix-os.sc.intel.com>
In-Reply-To: <20051220180929.B19129@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Cc: Nathan Lynch <ntl@pobox.com>, Yanmin Zhang <ymzhang@unix-os.sc.intel.com>, greg@kroah.com, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, Siddha Suresh B <suresh.b.siddha@intel.com>, Shah Rajesh <rajesh.shah@intel.com>, Pallipadi Venkatesh <venkatesh.pallipadi@intel.com>

Zhang, Yanmin wrote:
> 
> >>In practice does the division of bits between core and thread in the
> >>apic id differ between cpus in the same system?
>
> 2) On ia64, ia64 manual says that cpu physical id/core id/thread id are got by pal call. It doesn't mention how to divide apic id to get physical id/core id/thread id.

The socket_id, core_id, and thread_id are part of cpuinfo_ia64.
They are set up in arch/ia64/kernel/smpboot.c: identify_siblings()

You cannot make assumptions about "the division of bits", but must rely on
the values returned by pal.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
