From: Roland McGrath <roland@redhat.com>
Date: Tue, 07 Aug 2007 07:13:16 +0000
Subject: Re: [PATCH]utrace: IA64 RSE bug
Message-Id: <20070807071316.801494D04C4@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186464229.784.9.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1186464229.784.9.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

That looks reasonable to me, not being expert on the ia64 details.  
I rolled that into utrace-regset-ia64.patch in the 2.6.22 backport version.

> patch is against latest utrace source (2.6.22 base + utrace patches)

The latest utrace source is based on 2.6.23-rc2, and your patch does not
apply there.  TIF_NOTIFY_RESUME has been renamed to TIF_PERFMON_WORK.
So you need to rename it back (or to something else) to overload it.

If the gist of your patch here seems right to ia64 folks, then I'd suggest
you do a patch adding ia64_sync_krbs to the upstream kernel.  That would be
the necessary prelude to doing the arch_ptrace_stop plan, which I can help
ia64 folks with later.  


Thanks,
Roland
