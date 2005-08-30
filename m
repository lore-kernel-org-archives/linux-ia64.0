From: david mosberger <dmosberger@gmail.com>
Date: Tue, 30 Aug 2005 18:38:17 +0000
Subject: Re: ip_contrack module refuses to load...
Message-Id: <ed5aea4305083011384b38ad1a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 8/30/05, Luck, Tony <tony.luck@intel.com> wrote:

> At first glance it looks like ia64 should not be treating the UP
> case differently from the SMP case.  UP kernels place the per-cpu
> data up in the top 64K (PERCPU_PAGE_SIZE) of the virtual address
> space mapped by DTR[1], just like SMP kernels do ...

That's true.

> so all the
> space allocation, mapping, and relocation code should be the same
> for UP and SMP ... shouldn't they?

No, in the UP case, we can simply map the per-CPU section in the
kernel image whereas in the SMP case, each CPU needs its own copy of
the per-CPU section.  To see this, look for per_cpu_init(): in the SMP
case, it copies the section, in the UP-case, it simply returns
__phys_per_cpu_start (a pointer into the per-CPU section).

  --david
-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
