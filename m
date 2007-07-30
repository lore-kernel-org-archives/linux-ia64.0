From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 30 Jul 2007 17:42:09 +0000
Subject: Re: [PATCH] remove unused TIF_NOTIFY_RESUME (take 2)
Message-Id: <20070730174209.GA26366@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070730093034.GD25162@frankl.hpl.hp.com> <20070730102115.cac237ea.akpm@linux-foundation.org>
In-Reply-To: <20070730102115.cac237ea.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, ak@suse.de, linux-ia64@vger.kernel.org, tony.luck@intel.com

Andrew,

On Mon, Jul 30, 2007 at 10:21:15AM -0700, Andrew Morton wrote:
> On Mon, 30 Jul 2007 02:30:34 -0700 Stephane Eranian <eranian@hpl.hp.com> wrote:
> 
> > This following patch removes the TIF_NOTIFY_RESUME flag for thread_info. It is unused
> > on all but the IA-64 architecture. This is take 2 of this patch. In this version,
> > The definition is removed but no re-numbering of the TIF flags is done to minimize
> > the possibility of errors and reduce the size of the patch.
> > 
> > For IA-64, we ran out of low-order bits (first 7 bits). Adding a bit for perfmon
> > would cause important code rescheduling changes in the kernel entry/exit path. Instead,
> > we replace TIF_NOTIFY_RESUME with TIF_PERFMON_WORK. This way we get very close to what the
> > new perfmon code base is doing.
> 
> This has been (painfully) maintained in -mm for quite a long time.  I've
> been waiting for everyone else to merge their stuff so I can get it in
> without disrupting them.  This has now happened.
> 
> I think it'd be better to merge the larger patch - it's a bit tidier and
> more tested, OK?
> 
I appreciate your effort and understand your pain at maintaining this kind
of patch. It seems that neither you or myself have received any complaints
on this patch so far, so I am fine with you using the older version instead.

Thanks.

--
-Stephane
