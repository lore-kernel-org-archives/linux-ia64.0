From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 14 Mar 2003 21:32:13 +0000
Subject: Re: [Linux-ia64] Pre-emption patch for IA-64
Message-Id: <marc-linux-ia64-105590709806116@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just FYI, I tried 2.5.64 out on my Bug Sur, and it seems to work ok
with the following exceptions:
  o the AT keyboard support seems broken (characters are slow to show
    up on the screen and are sometimes repeated)
  o agp support for 460GX causes a link failure

But by using a USB keyboard and turning off agp support, I was able to
get an SMP+preempt kernel going, and it seems fine.

Jesse

On Fri, Mar 14, 2003 at 01:24:44PM -0800, David Mosberger wrote:
> Peter Chubb has been working on adding preemption support to 2.5.  I
> applied his patch in the 2.5.64 patch.  I'm sure he would appreciate
> more people beating on it.
> 
> 	--david
> 
> >>>>> On Fri, 14 Mar 2003 11:21:21 -0600, Mario Smarduch <cms063@email.mot.com> said:
> 
>   Mario> Hi, we're trying to build a reliable low-latency system for
>   Mario> use in telco call processing carrier grade environments (on
>   Mario> rx2600 NEBS like servers) . One of the patches we're heavily
>   Mario> relying on is the 'Kernel Preemption' patch. First of we're
>   Mario> interested in the (i) status of this patch on IA-64 (ii) any
>   Mario> issues that you may have ran into.
> 
>   Mario> Our understanding is that the 'Preemption Patch' offers a
>   Mario> systematic scheduling checkpoint vs. 'low latency patch'
>   Mario> which examines the kernel for any long running code and based
>   Mario> on that preemption checks are inserted in the kernel proper
>   Mario> only (kernel.org) but addon packages may introduce long
>   Mario> latencies. While we plan to run with 1mS clock tick, low
>   Mario> latency and the preemption paches, the preemption patch is
>   Mario> viewed as a must to gurantee a bound on 'soft-realtime
>   Mario> response'.  Please point out if these assumption are somewhat
>   Mario> correct or is too much emphasis being placed on the
>   Mario> preemption patch, the soft-realtime response we're looking
>   Mario> for is 1mS.
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

