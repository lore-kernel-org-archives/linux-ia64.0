From: Steven Cole <scole@lanl.gov>
Date: Tue, 01 May 2001 17:23:14 +0000
Subject: Re: [Linux-ia64] [PATCH] 2.4.3-ac14 remove three IA-64 related orphans from Configure.help
Message-Id: <marc-linux-ia64-105590693005500@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005460@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005460@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 01 May 2001 09:49, Chris McDermott wrote:
> Actually, CONFIG_ITANIUM_PTCG is still required if you have systems with
> Itanium
> processor steppings less than B3. I still have some of these and I'm sure
> there are
> quite a few others out there who still do as well.

As far as I can tell, in both 2.4.4-ac2 and 2.4.4, CONFIG_ITANIUM_PTCG
is defined in arch/ia64/config.in, but not offered as a setable choice.  Here
is an example from that file:

if [ "$CONFIG_MCKINLEY" = "y" ]; then
        define_bool CONFIG_ITANIUM_PTCG y
        define_int CONFIG_IA64_L1_CACHE_SHIFT 7
        bool '  Enable McKinley A-step specific code' CONFIG_MCKINLEY_ASTEP_SPECIFIC
        if [ "$CONFIG_MCKINLEY_ASTEP_SPECIFIC" = "y" ]; then
          bool '   Enable McKinley A0/A1-step specific code' CONFIG_MCKINLEY_A0_SPECIFIC
        fi
fi

Here is the recently deleted entry from Configure.help:

> -Enable use of global TLB purge instruction (ptc.g)
> -CONFIG_ITANIUM_PTCG
> -  Say Y here if you want the kernel to use the IA-64 "ptc.g"
> -  instruction to flush the TLB on all CPUs.  Select N here if
> -  you're unsure.

If you need that entry restored to Configure.help, we can put it back in, with
a "retained orphan" note.

We have been trying to prune out uneeded material from Configure.help, and
this entry seemed to fit in that category.

Please let us know what you need.

Steven

