From: Roland McGrath <roland@redhat.com>
Date: Tue, 14 Aug 2007 09:13:15 +0000
Subject: Re: [PATCH]utrace: IA64 RSE bug
Message-Id: <20070814091315.E199E4D057D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186464229.784.9.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1186464229.784.9.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > If the gist of your patch here seems right to ia64 folks, then I'd
> > suggest you do a patch adding ia64_sync_krbs to the upstream kernel.
> > That would be the necessary prelude to doing the arch_ptrace_stop plan,
> > which I can help ia64 folks with later.
> Ok, this is the patch against 2.6.23-rc2

That patch is for a kernel that has "tracehook" calls, which is not the
upstream kernel.  If it's for 2.6.23-rc2+linux-2.6.23-rc2-utrace.patch,
that is not what was requested in the bit you just quoted.

To reiterate, I think ia64 folks should consider a version of your patch
for vanilla 2.6.23-rc3.  It sounded like there was some agreement on
re-integrating the flag bit conflicts.  The flag bit integration and the
meat of the patch is not particular to utrace.  If you do the upstream
version of this patch and ia64 folks consider it reasonable, then it can go
into the vanilla ia64 kernel soon.  Can you do that?  As I said before,
that patch would be the precursor to the arch_ptrace_stop support that
makes more cleanup of the vanilla kernel's ia64 ptrace code possible.
(Since this would now be a patch for the vanilla ia64 kernel, it would be
misleading to keep it in a thread with "utrace" in the Subject: line.)

If the low-level parts of the RSE-vs-debugger scheme will be going into the
vanilla kernel, then I would much prefer to have that happen and then have
the utrace ia64 patch be relative to that.


Thanks,
Roland
