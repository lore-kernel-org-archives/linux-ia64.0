From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 27 Apr 2004 00:20:55 +0000
Subject: Re: [RFC IA64 Hotplug] [Patch 3/7] sysfs_ia64.patch
Message-Id: <1083021514.13646.3.camel@bach>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX4041XvpFVjCRG00000170@orsmsx404.amr.corp.intel.com>
In-Reply-To: <ORSMSX4041XvpFVjCRG00000170@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2004-04-27 at 08:03, David Mosberger wrote:
> >>>>> On Sat, 24 Apr 2004 23:46:34 -0700, "Ashok Raj" <ashok.raj@intel.com> said:
> 
>   Ashok> +static DEFINE_PER_CPU(struct ia64_cpu, cpu_devices);
> 
> This seems to be ~100 bytes per CPU.  With 128 CPUs, that's ~13KB out
> of a max of 64KB.  Just a heads up...

David, you had me going there for a while.

It's 100 bytes out of 64k, because there's 64k per-cpu, right?

Thanks,
Rusty.
-- 
Anyone who quotes me in their signature is an idiot -- Rusty Russell

