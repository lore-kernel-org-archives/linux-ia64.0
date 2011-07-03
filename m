From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 03 Jul 2011 19:46:18 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <20110703194618.GB27022@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<201107012134.45881.ptesarik@suse.cz>
	<20110701195629.GA19057@elte.hu>
	<201107012244.57593.ptesarik@suse.cz>
In-Reply-To: <201107012244.57593.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org


* Petr Tesarik <ptesarik@suse.cz> wrote:

> > Do you expect distros to enable this boot option by default? I.e. 
> > would SuSE be willing to ship with a restrictive /dev/mem by 
> > default? That's really the wider goal we want to work towards.
> 
> I'm not really the decision-maker on this, but even though I don't 
> need it for crash, there are several other users which would have 
> to be fixed:
> 
> 1. hwinfo (EFI, MPTABLE and ACPI table parsing, analyzing video BIOS)
> 2. dmidecode (SMBIOS, DMI)
> 3. possibly others

But those tables wont be in regular RAM (they will be in ROM or in 
RAM marked non-RAM in a special way in the e820 tables).

dmidecode certainly works on Fedora.

> > Hm, why would the ability "dirty and/or flush an arbitrary 
> > physical cache line for testing purposes" be a DoS?
> 
> Effectively switching off CPU caches can slow things down quite a 
> bit... especially on a large SMP system. ;)

Flushing a cacheline isnt switching it off. You can already 'flush' 
the cache from user-space as well, by trashing it for example. So i 
don't see the DoS angle.

Thanks,

	Ingo
