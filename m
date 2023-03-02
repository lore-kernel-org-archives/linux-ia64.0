From: "H. Peter Anvin" <hpa@zytor.com>
Date: Thu, 02 Mar 2023 19:50:45 +0000
Subject: Re: [PATCH v3 00/24] Remove COMMAND_LINE_SIZE from uapi
Message-Id: <21F95EC4-71EA-4154-A7DC-8A5BA54F174B@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <mhng-e8b09772-24e5-4729-a0bf-01a9e4c76636@palmer-ri-x1c9a>
In-Reply-To: <mhng-e8b09772-24e5-4729-a0bf-01a9e4c76636@palmer-ri-x1c9a>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Palmer Dabbelt <palmer@dabbelt.com>, hca@linux.ibm.com
Cc: geert@linux-m68k.org, alexghiti@rivosinc.com, corbet@lwn.net, Richard Henderson <richard.henderson@linaro.org>, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@kernel.org, linux@armlinux.org.uk, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, chenhuacai@kernel.org, kernel@xen0n.name, monstr@monstr.eu, tsbogend@alpha.franken.de, James.Bottomley@hansenpartnership.com, deller@gmx.de, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, Paul Walmsley <paul.walmsley@sifive.com>, aou@eecs.berkeley.edu, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.osdn.me, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, chris@zankel.net, jcmvbkbc@gmail.com, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On March 1, 2023 7:17:18 PM PST, Palmer Dabbelt <palmer@dabbelt.com> wrote:
>On Tue, 14 Feb 2023 01:19:02 PST (-0800), hca@linux.ibm.com wrote:
>> On Tue, Feb 14, 2023 at 09:58:17AM +0100, Geert Uytterhoeven wrote:
>>> Hi Heiko,
>>> 
>>> On Tue, Feb 14, 2023 at 9:39 AM Heiko Carstens <hca@linux.ibm.com> wrote:
>>> > On Tue, Feb 14, 2023 at 08:49:01AM +0100, Alexandre Ghiti wrote:
>>> > > This all came up in the context of increasing COMMAND_LINE_SIZE in the
>>> > > RISC-V port.  In theory that's a UABI break, as COMMAND_LINE_SIZE is the
>>> > > maximum length of /proc/cmdline and userspace could staticly rely on
>>> > > that to be correct.
>>> > >
>>> > > Usually I wouldn't mess around with changing this sort of thing, but
>>> > > PowerPC increased it with a5980d064fe2 ("powerpc: Bump COMMAND_LINE_SIZE
>>> > > to 2048").  There are also a handful of examples of COMMAND_LINE_SIZE
>>> > > increasing, but they're from before the UAPI split so I'm not quite sure
>>> > > what that means: e5a6a1c90948 ("powerpc: derive COMMAND_LINE_SIZE from
>>> > > asm-generic"), 684d2fd48e71 ("[S390] kernel: Append scpdata to kernel
>>> > > boot command line"), 22242681cff5 ("MIPS: Extend COMMAND_LINE_SIZE"),
>>> > > and 2b74b85693c7 ("sh: Derive COMMAND_LINE_SIZE from
>>> > > asm-generic/setup.h.").
>>> > >
>>> > > It seems to me like COMMAND_LINE_SIZE really just shouldn't have been
>>> > > part of the uapi to begin with, and userspace should be able to handle
>>> > > /proc/cmdline of whatever length it turns out to be.  I don't see any
>>> > > references to COMMAND_LINE_SIZE anywhere but Linux via a quick Google
>>> > > search, but that's not really enough to consider it unused on my end.
>>> > >
>>> > > The feedback on the v1 seemed to indicate that COMMAND_LINE_SIZE really
>>> > > shouldn't be part of uapi, so this now touches all the ports.  I've
>>> > > tried to split this all out and leave it bisectable, but I haven't
>>> > > tested it all that aggressively.
>>> >
>>> > Just to confirm this assumption a bit more: that's actually the same
>>> > conclusion that we ended up with when commit 3da0243f906a ("s390: make
>>> > command line configurable") went upstream.
>
>Thanks, I guess I'd missed that one.  At some point I think there was some discussion of making this a Kconfig for everyone, which seems reasonable to me -- our use case for this being extended is syzkaller, but we're sort of just picking a value that's big enough for now and running with it.
>
>Probably best to get it out of uapi first, though, as that way at least it's clear that it's not uABI.
>
>>> Commit 622021cd6c560ce7 ("s390: make command line configurable"),
>>> I assume?
>> 
>> Yes, sorry for that. I got distracted while writing and used the wrong
>> branch to look this up.
>
>Alex: Probably worth adding that to the list in the cover letter as it looks like you were planning on a v4 anyway (which I guess you now have to do, given that I just added the issue to RISC-V).

The only use that is uapi is the *default* length of the command line if the kernel header doesn't include it (in the case of x86, it is in the bzImage header, but that is atchitecture- or even boot format-specific.)
