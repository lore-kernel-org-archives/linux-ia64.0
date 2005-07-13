From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Wed, 13 Jul 2005 03:56:21 +0000
Subject: Re: [PATCH]Kprobes IA64 - Fix race when break hits and kprobe not found
Message-Id: <20050712205620.A9292@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050712185230.A8528@unix-os.sc.intel.com> <20050712190231.789da83c.akpm@osdl.org>
In-Reply-To: <20050712190231.789da83c.akpm@osdl.org>; from akpm@osdl.org on Tue, Jul 12, 2005 at 07:02:31PM -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, prasanna@in.ibm.com

On Tue, Jul 12, 2005 at 07:02:31PM -0700, Andrew Morton wrote:
> Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com> wrote:
> >
> > This patch applies on top of  "Prasanna S Panchamukhi's" recent postings
> >  Kprobes: Prevent possible race condition ia64 changes
> 
> I am not aware of such a patch.  Your patch hit a reject when I tried to
> apply it to Linus's tree.  So I don't know what's going on..

Andrew,
	I thought you might have applied http://marc.theaimsgroup.com/?l=linux-kernel&m2082142008250&w=2 hence I generated my patch on top of this.

No problem, I will generate this patch against Linus's tree (as this does not really depend on any other patches) and submit it again in couple of hours. 
Let me know if this is okay.

-thanks,
-Anil
