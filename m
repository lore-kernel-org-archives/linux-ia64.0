From: Jay Lan <jlan@sgi.com>
Date: Wed, 10 Sep 2008 20:21:35 +0000
Subject: Re: kdump broken on Altix 350
Message-Id: <48C82C4F.1050002@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080829180302.6e67c26e@halley.suse.de>	<20080829180531.0524a1e4@halley.suse.de>	<57C9024A16AD2D4C97DC78E552063EA30A0067D6@orsmsx505.amr.corp.intel.com>
	<20080910134805.488b43f9@kepler.site>
In-Reply-To: <20080910134805.488b43f9@kepler.site>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bwalle@suse.de>
Cc: linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, kexec@lists.infradead.org, Simon Horman <horms@verge.net.au>

Bernhard Walle wrote:
> * "Luck, Tony" <tony.luck@intel.com> [2008-08-29]: 
> 
>>> your commit
>>>
>>>     commit 10617bbe84628eb18ab5f723d3ba35005adde143
>>>     Author: Tony Luck <tony.luck@intel.com>
>>>     Date:   Tue Aug 12 10:34:20 2008 -0700
>>>
>>>     [IA64] Ensure cpu0 can access per-cpu variables in early boot
>>> code
>>>
>>> broke kdump on our Altix 350. I get following early crash in kdump
>>> kernel
>> Sorry about that.  I'll try to reproduce it here.
> 
> I had some discussion about that with Jay Lan that he could not
> reproduce that on his machine. We thought it was different config, but
> now I can verify that the problem is reproducible here with the default
> configuration (plus CONFIG_SATA_VITESSE).

Hi Bernhard and Tony,

I started seeing this problem, and it affected A4700 in addition to
A350.

It was not clear the system hang was related to this problem. I saw a
kdump kernel hang at cpu_init() at an A350, and a hang in find_memory
on handling pernode space thing at an A4700. No error records and no
backtrace, so i did not relate my problem to this one at first.

Out of curiosity, i backed out Tony's patch mentioned from 2.6.27-rc5
and the kdump kernel hangs were gone on both systems.

Also, i had a kdump kernel MCA problem that was caused by kexec
underallocating kernel memory for the kdump kernel. The  problem
does not happen again after i backed out the patch.

Regards,
jay

> 
> 
> Bernhard
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec

