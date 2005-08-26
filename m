From: Keith Owens <kaos@sgi.com>
Date: Fri, 26 Aug 2005 00:38:41 +0000
Subject: Re: Global Purge Translation Cache on NUM systems
Message-Id: <7735.1125016721@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <A752C16E6296D711942200065BFCB69424BFFF47@il02exm10>
In-Reply-To: <A752C16E6296D711942200065BFCB69424BFFF47@il02exm10>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 25 Aug 2005 13:15:33 -0500, 
Smarduch Mario-CMS063 <CMS063@motorola.com> wrote:
>
>We've been noticing some TLB issues on 2.4 and 2.6.10 kernels running
>on IA64 NUMA architecture. To this end I have some questions regarding
>TLB purging, please bare through with the initial introduction.
>
>IA64 Inst Set Manual points out that propogation of ptc.g across local
>cache coherence domains is platform dependent and must be handled by
>software. I'm trying to understand how would this work on a ccNUMA and
>whether or not software beyond what hw offers to propgate a ptc.ga
>(Purte TC bus transaction) is needed.

See platform_global_tlb_purge.  On ccNUMA boxes it gets defined to a
platform specific routine.  On SGI's SN2, platform_global_tlb_purge
ends up calling sn2_global_tlb_purge().  That routine works out if the
flush is for the current cpu, for a cpu on the same node or for a
remote node and handles the flush accordingly.

>When a Purge TC global is issued is hardware responsible for keeping the xaction from completion (TND#
>assertion) until the xaction has become visible to all nodes?

The platform's tlb purge routine is responsible for synchronization.
It must not return to the caller of platform_global_tlb_purge() until
the tlb has been flushed on all the target nodes.  IOW, software make
non-sync hardware look synchronous.

