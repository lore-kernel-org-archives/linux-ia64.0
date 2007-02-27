From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 27 Feb 2007 20:24:27 +0000
Subject: Re: debug registers and fork
Message-Id: <20070227122427.bf23af2f.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070226235154.GB19630@frankl.hpl.hp.com>
In-Reply-To: <20070226235154.GB19630@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, ak@suse.de, tony.luck@intel.com, Roland McGrath <roland@redhat.com>

> On Mon, 26 Feb 2007 15:51:54 -0800 Stephane Eranian <eranian@hpl.hp.com> wrote:
> Hello,
> 
> I have come across an issue with a monitoring using the
> hardware debug registers on ia64/i386/x86-64.
> 
> It seems that the way debug registers are inherited across fork
> differs between ia-64 and i386/x86-64. On ia-64, the debug registers
> are NEVER inherited in the child. The copy_thread() routine clears
> the necessary thread flags to avoid reloading the debug registers in
> the child.
> 
> Now, on x86-64, it appears that the TIF_DEBUG flag is inherited via
> setup_thread_stack(). By virtue of dup_task_struct() the debug registers
> get copied into the child task on fork. So the child has active breakpoints,
> unless I am mistaken somewhere.
> 
> Given the way the ptrace() interface works, I would tend to
> think that the ia-64 way is the correct one. Any comment?
> 
> Furthermore, on i386/x86-64, when switching out from a task with TIF_DEBUG
> enabled to another which does not, it seems we do not clear the debug
> registers (at least dr7) so they become inactive.
> 

Let's cc Roland - he's totally rewritten ptrace and probably knows this
stuff.
