From: "Chris McDermott" <mcdermoc@us.ibm.com>
Date: Tue, 01 May 2001 18:05:16 +0000
Subject: Re: [Linux-ia64] [PATCH] 2.4.3-ac14 remove three IA-64 related orphans from
Message-Id: <marc-linux-ia64-105590693005509@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005460@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005460@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Steven,

You are correct, arch/ia64/config.in now sets CONFIG_ITANIUM_PTCG,
based on the user-setable choices CONFIG_ITANIUM_?STEP_SPECIFIC
and CONFIG_ITANIUM_B?_SPECIFIC. So, assuming the user gets those
right, they'll get the correct value for CONFIG_ITANIUM_PTCG and the
correct behavior on their system. Since this config option is temporary
anyway (only required for early processor steppings) and since it's
already been pulled out of Configure.help (I think cleaning this file up
is a good idea), I would say leave it out.

Chris McDermott
IBM Linux Technology Center (LTC)
IA-64 Enablement





> As far as I can tell, in both 2.4.4-ac2 and 2.4.4, CONFIG_ITANIUM_PTCG
> is defined in arch/ia64/config.in, but not offered as a setable choice.
Here
> is an example from that file:
>
> if [ "$CONFIG_MCKINLEY" = "y" ]; then
>        define_bool CONFIG_ITANIUM_PTCG y
>        define_int CONFIG_IA64_L1_CACHE_SHIFT 7
>        bool '  Enable McKinley A-step specific code'
CONFIG_MCKINLEY_ASTEP_SPECIFIC
>        if [ "$CONFIG_MCKINLEY_ASTEP_SPECIFIC" = "y" ]; then
>          bool '   Enable McKinley A0/A1-step specific code'
CONFIG_MCKINLEY_A0_SPECIFIC
>        fi
> fi
>
> Here is the recently deleted entry from Configure.help:
>
> > -Enable use of global TLB purge instruction (ptc.g)
> > -CONFIG_ITANIUM_PTCG
> > -  Say Y here if you want the kernel to use the IA-64 "ptc.g"
> > -  instruction to flush the TLB on all CPUs.  Select N here if
> > -  you're unsure.
>
> If you need that entry restored to Configure.help, we can put it back in,
with
> a "retained orphan" note.
>
> We have been trying to prune out uneeded material from Configure.help,
and
> this entry seemed to fit in that category.
>
> Please let us know what you need.
>
> Steven




