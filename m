From: david mosberger <dmosberger@gmail.com>
Date: Thu, 14 Jul 2005 18:09:21 +0000
Subject: Re: [RFC][patch 2/10] Multiple vector domain support - cpu and domain management
Message-Id: <ed5aea4305071411096f9ddee6@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42D62E73.1050108@jp.fujitsu.com>
In-Reply-To: <42D62E73.1050108@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I didn't have time to look at these patches yet, but what I was
wondering: SGI Altix already does per-CPU interrupts.  Do we really
need another abstraction or could you use the same approach as SGI?

  --david

On 7/14/05, Ashok Raj <ashok.raj@intel.com> wrote:
> On Thu, Jul 14, 2005 at 06:20:51PM +0900, Kenji Kaneshige wrote:
> >
> > This patch add the code to handle the relationship between cpu and
> > domains. We need more consideration about how to separate vector
> > domains.
> >
> > Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> >
> > ---
> >
> 
> Should we consider this based on some mach-* like schemes, so for e.g in
> NUMA case we could use node as a VECTOR_DOMAIN? ... or maybe we could
> somehow tie this into CPUSETS?..
> 
> > +
> > +#ifdef CONFIG_VECTOR_DOMAIN
> > +int ia64_cpu_domain_map[NR_CPUS];
> > +cpumask_t ia64_domain_cpumask[NR_VECTOR_DOMAINS];
> > +
> > +void __devinit
> > +ia64_attach_cpu_to_domain (int cpu)
> > +{
> > +     static int domain = -1;
> > +
> > +     /* Simple Round Robin for now */
> > +     if (++domain >= NR_VECTOR_DOMAINS)
> > +             domain = 0;
> > +     ia64_cpu_domain_map[cpu] = domain;
> > +     cpu_set(cpu, ia64_domain_cpumask[domain]);
> > +}
> > +#endif /* CONFIG_VECTOR_DOMAIN */
> 
> --
> Cheers,
> Ashok Raj
> - Open Source Technology Center
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
