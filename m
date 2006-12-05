From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 05 Dec 2006 22:28:10 +0000
Subject: Re: [perfmon] 2.6.19 new perfmon code base + libpfm + pfmon
Message-Id: <20061205222810.GA6385@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061204164644.GO31914@frankl.hpl.hp.com> <4575AB54.2050509@redhat.com>
In-Reply-To: <4575AB54.2050509@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Cohen <wcohen@redhat.com>
Cc: eranian@hpl.hp.com, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, oprofile-list@lists.sourceforge.net, perfctr-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org

On Tue, Dec 05, 2006 at 12:24:36PM -0500, William Cohen wrote:
> Some of the ptrace functions (e.g. ptrace_may_attach in perfmon_syscall.c) 
> being used in the perfmon kernel patches will go away with the utrace 
> patches: http://people.redhat.com/roland/utrace/

At least for ptrace_may_attach that's not true in the lastest version
from Roland - in fact it's the last unconditional function in ptrace.c
in that version.  I suggested to him to rename and move it in my review,
though.

