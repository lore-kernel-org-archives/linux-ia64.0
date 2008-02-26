From: Alex Chiang <achiang@hp.com>
Date: Tue, 26 Feb 2008 17:51:44 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC]
Message-Id: <20080226175144.GB15862@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Li, Shaohua <shaohua.li@intel.com>:
> >
> >Do you get anything useful (like the oops message) printed on the
> >console or in your syslog?
> >
> >That might be a good first step.
> SAL: AP wakeup using external interrupt vetor 0xf0
> swapper[0]: IA-64 Illegal operation fault 0
> Modules linked in:
> Pid:0
> CPU 0
> comm: swapper
> psr: 00001010084a2010 ifs:8000000000000818 ip:[<e00000017fe510f0>] Not
> tained(2.6.24)
> ip is at 0xe00000017fe510f0

This looks like an identity-mapped firmware address. Can you send
the output of the EFI memmap command?

> unat:0000000000000 pfs0000000000038f rsc0000000000003
> rnat 0000000000000 bsps 0000000000000, pr 656960155aa6809b
> ldrs:000000000 ccv 00000000000 fpsr 0009804c8a70433f
> ...........
> 
> 
> I can't get the log with serial console, so I copied by hand, so maybe
> there are errors. There are a lot of other registers below, if you need
> know, I'll copy them too

How about taking a picture with a camera and sticking it
somewhere? :)

In the mean time, I'll try and reproduce this with the tiger we
have here.

Thanks.

/ac

