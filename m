From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 08 Feb 2006 02:17:47 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <200602080217.k182Hlg23826@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060208020832.GK3524@stusta.de>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Adrian Bunk' <bunk@stusta.de>
Cc: Keith Owens <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Adrian Bunk wrote on Tuesday, February 07, 2006 6:09 PM
> > CONFIG_IA64_GENERIC is a platform type choice, you can have platform
> > type of DIG, HPZX1, SGI SN2, or all of the above.  DIG platform depends
> > on ACPI, thus need ACPI on.  SGI altix is a numa box, thus, need NUMA
> > on.  NEC, Fujitsu build numa machines with ACPI SRAT table, thus, need
> > ACPI_NUMA on.  When you build a kernel to boot on all platforms, you
> > have no choice but to turn on all of the above.  Processor type and SMP
> > is different from platform type.  It does not have any dependency on
> > platform type.  They are orthogonal choice.
> 
> This is interesting, considering that e.g. IA64_SGI_SN2=y, NUMA=n or 
> IA64_DIG=y, ACPI=n are currently allowed configurations.

Right, that is what Matthew Wilcox said in earlier thread.


> > > Keith said IA64_GENERIC should select all the options required in
> > > order to run on all the IA64 platforms out there.
> >                           ^^^^^^^^^^^^^^
> > > This is what my patch does.
> > 
> > You patch does more than what you described and is wrong.  Selecting
> > platform type should not be tied into selecting SMP nor should it tied
> 
> This was what Keith wanted.
> 
> It seems everyone thinks I am wrong, but when I'm implementing what one 
> person suggests, other people say that what I am doing is wrong.

You have to digest what people say and *understand* why they said what they
say. Checking earlier thread, Keith did not say "select CONFIG_ITANIUM
for generic ia64 platforms".


> > Theoretically and maybe academically interesting, I should be able to
> > build a kernel that boots on all UP platforms, with your patch, that
> > is not possible.
> 
> Theoretically and maybe academically interesting, I should be able to 
> build a kernel that boots on all non-NUMA platforms, currently, that is 
> not possible.

This is going too far and very childish in my opinion. I'm going to shut
up.

- Ken

