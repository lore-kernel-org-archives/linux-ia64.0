From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Tue, 29 Aug 2006 19:55:03 +0000
Subject: Re: Move perfmon tables from thread_struct to pfm_context
Message-Id: <20060829125502.A24069@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829110856.A23515@unix-os.sc.intel.com>
In-Reply-To: <20060829110856.A23515@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 29, 2006 at 08:55:28PM +0100, Christoph Hellwig wrote:
> On Tue, Aug 29, 2006 at 11:08:56AM -0700, Keshavamurthy Anil S wrote:
> > This patch renders thread_struct->pmcs[] and thread_struct->pmds[]
> > OBSOLETE. The actual table is moved to pfm_context structure which 
> > is the right thing to do. Also this will in future avoid KABI breakages
> > for the distro as well when the table size changes.
> 
> NACK.  There is no such thing as a KABI, and any patch the claims to
> help towards it will automatically be rejected.  You should get a doctor
> to help you stop seeing things like that.
You have not fully understood the benifit of this patch. Moving pmds[] and pmcs[]
away from thread_struct saves that much space from the thread_struct
and in turns saves that much spaces from the task_struct. Again by moving
this table to pfm_context makes it possible that this table space is 
created only when pfm_context_alloc() is called which is 
when this is really required. This patch in fact reduces the sizeof task_struct
and their by allowing that extra space for the kernel stacks use :)

Please relook at the benifits of this patch again.

-Anil
