From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 24 Jan 2006 22:07:02 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601242207.k0OM72g15067@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Tuesday, January 24, 2006 1:51 PM
> > +	.last_cpu	= 0,			\
> 
> How does .last_cpu get propagated to new processes, and what is
> it initialized to?  Right now it looks like there is an odd
> quirk that we'll call platform_switch_from() as each process starts
> running for the first time [or is the whole thread_info structure
> copied from the parent someplace that I didn't notice].


I think it is copy from dup_task_struct(): setup_thread_stack(tsk, orig)

and

void setup_thread_stack(struct task_struct *p, struct task_struct *org)
{
        *task_thread_info(p) = *task_thread_info(org);
        task_thread_info(p)->task = p;
}

