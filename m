From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 05 Aug 2002 01:19:13 +0000
Subject: Re: [Linux-ia64] Re: CPU hotplug boot change for IA64
Message-Id: <marc-linux-ia64-105590701905904@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In message <20020802210541.0AB4.K-SUGANUMA@mvj.biglobe.ne.jp> you write:
> Hi Rusty,
> 
> On Sat, 03 Aug 2002 13:29:02 +1000
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> 
> > > Rusty, I guess this modification should be needed for i386, too.
> > 
> > You should *not* be calling smp_call_function before smp_prepare_cpus.
> > 
> > I know kgdb can do this, but it's a special case.
> 
> OK.
> I cannot remember who was calling smp_call_function, but I think
> it might be kdb. I'm using kdb for debugging in usual.

Yes, in which case the fix I asked Andrew Morton to use was:

	/* Before smp_prepare_cpus, cpu_online not usable */
	if (num_online_cpus() > 1)
		smp_call_function(...)

Cheers,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

