From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 03 Aug 2002 03:29:02 +0000
Subject: [Linux-ia64] Re: CPU hotplug boot change for IA64
Message-Id: <marc-linux-ia64-105590701905902@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In message <20020802134915.ED77.K-SUGANUMA@mvj.biglobe.ne.jp> you write:
> Bit for CPU#0 on cpu_online_map was set at smp_boot_cpus() before.
> But on the 2.5.29, place of calling smp_boot_cpus() is changed to
> later timing and this seems to make a chance that smp_call_function()
> is called before setting cpu_online_map, (I guess.)
> In that case, smp_call_function won't return because num_online_cpus()
> returns 0 and the system will hang.
> 
> I have an experience of this problem only on a large system
> like Tiger, but it may occur on another system.
> 
> Rusty, I guess this modification should be needed for i386, too.

You should *not* be calling smp_call_function before smp_prepare_cpus.

I know kgdb can do this, but it's a special case.

Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

