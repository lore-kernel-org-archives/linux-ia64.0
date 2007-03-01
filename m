From: Alan Stern <stern@rowland.harvard.edu>
Date: Thu, 01 Mar 2007 00:01:17 +0000
Subject: Re: debug registers and fork
Message-Id: <Pine.LNX.4.44L0.0702281847330.24215-100000@netrider.rowland.org>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070228212510.1E213180067@magilla.sf.frob.com>
References: <20070226235154.GB19630@frankl.hpl.hp.com>
In-Reply-To: <20070226235154.GB19630@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, eranian@hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, ak@suse.de, tony.luck@intel.com, William Cohen <wcohen@redhat.com>

On Wed, 28 Feb 2007, Roland McGrath wrote:

> It is true that debug registers are inherited by fork and clone.
> I am 99% sure that this was never specifically intended, but it
> has been this way for a long time (since 2.4 at least).  It's an
> implicit consequence of the do_fork implementation style, which
> does a blind copy of the whole task_struct and then explicitly
> reinitializes some individual fields.  I suppose this has some
> benefit or other, but it is very prone to new pieces of state
> getting implicitly copied without the person adding that new state
> ever consciously deciding what its inheritance semantics should be.
> 
> Alan Stern is working on a revamp of the x86 debug register
> support.  This is a fine opportunity to clean this area up and
> decide positively what the semantics ought to be.

Absolutely.  Right now I just have a placeholder function with a note
about checking for CLONE_PTRACE.  The cleanest solution, far and away,
would be to have the child process inherit no breakpoints and no debug
register values.

Alan Stern

