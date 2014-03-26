From: Andrew Cooper <andrew.cooper3@citrix.com>
Date: Wed, 26 Mar 2014 22:35:39 +0000
Subject: Re: [Xen-devel] [PATCH v3 3/5] x86: Call efi_memblock_x86_reserve_range() on native EFI platform onl
Message-Id: <5333563B.2060601@citrix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>	<1395781076-12000-4-git-send-email-daniel.kiper@oracle.com>	<20140326130009.GB24856@console-pimps.org>	<5332E2B9020000780000255D@nat28.tlf.novell.com>	<20140326133119.GD24856@console-pimps.org>	<5332E6AE02000078000025F0@nat28.tlf.novell.com>	<20140326134845.GN3454@olila.local.net-space.pl>	<20140326135723.GG24856@console-pimps.org> <20140326220132.GQ3454@olila.local.net-space.pl>
In-Reply-To: <20140326220132.GQ3454@olila.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Daniel Kiper <daniel.kiper@oracle.com>, Matt Fleming <matt@console-pimps.org>
Cc: fenghua.yu@intel.com, jeremy@goop.org, matt.fleming@intel.com, linux-ia64@vger.kernel.org, ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com, linux-efi@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, david.vrabel@citrix.com, Jan Beulich <JBeulich@suse.com>, hpa@zytor.com, xen-devel@lists.xenproject.org, tglx@linutronix.de, mingo@redhat.com, boris.ostrovsky@oracle.com, eshelton@pobox.com

On 26/03/2014 22:01, Daniel Kiper wrote:
> On Wed, Mar 26, 2014 at 01:57:23PM +0000, Matt Fleming wrote:
>> On Wed, 26 Mar, at 02:48:45PM, Daniel Kiper wrote:
>>> On my machine this function crashes on Xen so that is why I have changed
>>> condition. However, if you say that this issue could be solved in
>>> another way I will investigate it further.
>> Daniel, could you paste the crash? Do you get a stack trace?
> Here it is:
>
> [...]
>
> mapping kernel into physical memory
> about to get started...
> (XEN) traps.c:458:d0v0 Unhandled divide error fault/trap [#0] on VCPU 0 [=
ec=0000]
> (XEN) domain_crash_sync called from entry.S: fault at ffff82d080229d30 in=
t80_direct_trap+0x200/0x210
> (XEN) Domain 0 (vcpu#0) crashed on cpu#0:
> (XEN) ----[ Xen-4.5-unstable  x86_64  debug=3Dy  Tainted:    C ]----
> (XEN) CPU:    0
> (XEN) RIP:    e033:[<ffffffff816987c5>]
> (XEN) RFLAGS: 0000000000000246   EM: 1   CONTEXT: pv guest
> (XEN) rax: 0000000000000000   rbx: 0000000001000000   rcx: 00000000000000=
00
> (XEN) rdx: 0000000000000000   rsi: ffffffff814d7e7e   rdi: 00000000000000=
00
> (XEN) rbp: ffffffff81601e88   rsp: ffffffff81601e48   r8:  00000000000000=
00
> (XEN) r9:  0000000000007ff0   r10: 00000000deadbeef   r11: ffffffff81601d=
f8
> (XEN) r12: ffffffff816fe010   r13: ffffffff81601f00   r14: 00000000000000=
00
> (XEN) r15: 0000000000000000   cr0: 0000000080050033   cr4: 00000000000026=
f0
> (XEN) cr3: 000000007b60d000   cr2: 0000000000000000
> (XEN) ds: 0000   es: 0000   fs: 0000   gs: 0000   ss: e02b   cs: e033
> (XEN) Guest stack trace from rsp=FFffffff81601e48:
> (XEN)    0000000000000000 ffffffff81601df8 ffffffff816987c5 000000010000e=
030
> (XEN)    0000000000010046 ffffffff81601e88 000000000000e02b ffffffff81601=
f00
> (XEN)    ffffffff81601ed8 ffffffff8168a1a4 ffffffff81601ee8 ffffffff81601=
ea8
> (XEN)    ffff880001e16490 ffffffffffffffff ffffffff816fe010 0000000000000=
000
> (XEN)    0000000000000000 0000000000000000 ffffffff81601f28 ffffffff81685=
a3e
> (XEN)    0000000000000000 0000000000000000 0000000000000000 0000000000000=
000
> (XEN)    ffff880001e16000 0000000000000000 0000000000000000 0000000000000=
000
> (XEN)    ffffffff81601f38 ffffffff816854c8 ffffffff81601ff8 ffffffff81687=
442
> (XEN)    0000000100000000 0000080000000623 0789cbf580802001 0300000100000=
032
> (XEN)    0000000000000005 0000000000000000 0000000000000000 0000000000000=
000
> (XEN)    0000000000000000 0000000000000000 0000000000000000 0000000000000=
000
> (XEN)    0000000000000000 0000000000000000 0000000000000000 0000000000000=
000
> (XEN)    0000000000000000 0000000000000000 0000000000000000 0000000000000=
000
> (XEN)    0000000000000000 0000000000000000 0000000000000000 0f00000060c0c=
748
> (XEN)    ccccccccccccc305 cccccccccccccccc cccccccccccccccc ccccccccccccc=
ccc
> (XEN)    cccccccccccccccc cccccccccccccccc cccccccccccccccc ccccccccccccc=
ccc
> (XEN)    cccccccccccccccc cccccccccccccccc cccccccccccccccc ccccccccccccc=
ccc
> (XEN)    cccccccccccccccc cccccccccccccccc cccccccccccccccc ccccccccccccc=
ccc
> (XEN)    cccccccccccccccc cccccccccccccccc cccccccccccccccc ccccccccccccc=
ccc
> (XEN)    cccccccccccccccc cccccccccccccccc cccccccccccccccc ccccccccccccc=
ccc
> (XEN) Domain 0 crashed: rebooting machine in 5 seconds.
>
> Some addresses are solved to:
> 0xffffffff816987c5: efi_memblock_x86_reserve_range at arch/x86/platform/e=
fi/efi.c:393
> 0xffffffff8168a1a4: setup_arch at arch/x86/kernel/setup.c:940
> 0xffffffff81685a3e: setup_command_line at init/main.c:353
> 0xffffffff816854c8: x86_64_start_reservations at arch/x86/kernel/head64.c=
:194
> 0xffffffff81687442: xen_start_kernel at arch/x86/xen/enlighten.c:1733
>
> I am using Linus tree with latest commit b098d6726bbfb94c06d6e1097466187a=
fddae61f
> (Linux 3.14-rc8) with my patches applied excluding patch 3.
>
> Daniel

Then all you need to do is look up ffffffff816987c5 in your linux
symbols, and whichever variable is being divided on that line of source
has ether has the value 0 or -1.=20

~Andrew
