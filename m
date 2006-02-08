From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 08 Feb 2006 01:40:13 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <200602080140.k181eDg20764@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060208011938.GJ3524@stusta.de>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Adrian Bunk' <bunk@stusta.de>
Cc: Keith Owens <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Adrian Bunk wrote on Tuesday, February 07, 2006 5:20 PM
> You could ask the same question for NUMA:
> Select generic system type does not mean NUMA systems are only choice I 
> can have. What's wrong with having an option that works just fine?

Please read more ia64 arch specific code ...

CONFIG_IA64_GENERIC is a platform type choice, you can have platform
type of DIG, HPZX1, SGI SN2, or all of the above.  DIG platform depends
on ACPI, thus need ACPI on.  SGI altix is a numa box, thus, need NUMA
on.  NEC, Fujitsu build numa machines with ACPI SRAT table, thus, need
ACPI_NUMA on.  When you build a kernel to boot on all platforms, you
have no choice but to turn on all of the above.  Processor type and SMP
is different from platform type.  It does not have any dependency on
platform type.  They are orthogonal choice.


> Keith said IA64_GENERIC should select all the options required in
> order to run on all the IA64 platforms out there.
                          ^^^^^^^^^^^^^^
> This is what my patch does.

You patch does more than what you described and is wrong.  Selecting
platform type should not be tied into selecting SMP nor should it tied
with processor type, nor should it tied with ARCH_FLATMEM_ENABLE.  All
of them are orthogonal and independent.

Theoretically and maybe academically interesting, I should be able to
build a kernel that boots on all UP platforms, with your patch, that
is not possible.

- Ken

