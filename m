From: Keith Owens <kaos@sgi.com>
Date: Wed, 08 Feb 2006 02:48:10 +0000
Subject: Re: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <10378.1139366890@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Tue, 07 Feb 2006 17:40:13 -0800."
             <200602080140.k181eDg20764@unix-os.sc.intel.com> 
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Adrian Bunk' <bunk@stusta.de>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

"Chen, Kenneth W" (on Tue, 7 Feb 2006 17:40:13 -0800) wrote:
>Adrian Bunk wrote on Tuesday, February 07, 2006 5:20 PM
>> You could ask the same question for NUMA:
>> Select generic system type does not mean NUMA systems are only choice I 
>> can have. What's wrong with having an option that works just fine?
>
>Please read more ia64 arch specific code ...
>
>CONFIG_IA64_GENERIC is a platform type choice, you can have platform
>type of DIG, HPZX1, SGI SN2, or all of the above.  DIG platform depends
>on ACPI, thus need ACPI on.  SGI altix is a numa box, thus, need NUMA
>on.  NEC, Fujitsu build numa machines with ACPI SRAT table, thus, need
>ACPI_NUMA on.  When you build a kernel to boot on all platforms, you
>have no choice but to turn on all of the above.  Processor type and SMP
>is different from platform type.  It does not have any dependency on
>platform type.  They are orthogonal choice.
>
>
>> Keith said IA64_GENERIC should select all the options required in
>> order to run on all the IA64 platforms out there.
>                          ^^^^^^^^^^^^^^
>> This is what my patch does.
>
>You patch does more than what you described and is wrong.  Selecting
>platform type should not be tied into selecting SMP nor should it tied
>with processor type, nor should it tied with ARCH_FLATMEM_ENABLE.  All
>of them are orthogonal and independent.

Blame me for the SMP bit.  I have a dim, distant memory that Intel
required all IA64 boxes to be SMP, but I could be wrong.  Also it is
almost pointless to do a generic build which pulls in NUMA etc.,
without also including SMP.

