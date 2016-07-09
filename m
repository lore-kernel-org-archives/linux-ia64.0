From: Ingo Molnar <mingo@kernel.org>
Date: Sat, 09 Jul 2016 07:55:40 +0000
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Message-Id: <20160709075539.GA27852@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <b113b487-acc6-24b8-d58c-425d3c884f4c@redhat.com>
 <1468032243.13253.59.camel@redhat.com>
In-Reply-To: <1468032243.13253.59.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Rik van Riel <riel@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com


* Rik van Riel <riel@redhat.com> wrote:

> On Fri, 2016-07-08 at 19:22 -0700, Laura Abbott wrote:
> >=A0
> > Even with the SLUB fixup I'm still seeing this blow up on my arm64
> > system. This is a
> > Fedora rawhide kernel + the patches
> >=20
> > [=A0=A0=A0=A00.666700] usercopy: kernel memory exposure attempt detecte=
d from
> > fffffc0008b4dd58 (<kernel text>) (8 bytes)
> > [=A0=A0=A0=A00.666720] CPU: 2 PID: 79 Comm: modprobe Tainted:
> > G=A0=A0=A0=A0=A0=A0=A0=A0W=A0=A0=A0=A0=A0=A0=A04.7.0-0.rc6.git1.1.harde=
nedusercopy.fc25.aarch64 #1
> > [=A0=A0=A0=A00.666733] Hardware name: AppliedMicro Mustang/Mustang, BIOS
> > 1.1.0 Nov 24 2015
> > [=A0=A0=A0=A00.666744] Call trace:
> > [=A0=A0=A0=A00.666756] [<fffffc0008088a20>] dump_backtrace+0x0/0x1e8
> > [=A0=A0=A0=A00.666765] [<fffffc0008088c2c>] show_stack+0x24/0x30
> > [=A0=A0=A0=A00.666775] [<fffffc0008455344>] dump_stack+0xa4/0xe0
> > [=A0=A0=A0=A00.666785] [<fffffc000828d874>] __check_object_size+0x6c/0x=
230
> > [=A0=A0=A0=A00.666795] [<fffffc00083a5748>] create_elf_tables+0x74/0x420
> > [=A0=A0=A0=A00.666805] [<fffffc00082fb1f0>] load_elf_binary+0x828/0xb70
> > [=A0=A0=A0=A00.666814] [<fffffc0008298b4c>] search_binary_handler+0xb4/=
0x240
> > [=A0=A0=A0=A00.666823] [<fffffc0008299864>] do_execveat_common+0x63c/0x=
950
> > [=A0=A0=A0=A00.666832] [<fffffc0008299bb4>] do_execve+0x3c/0x50
> > [=A0=A0=A0=A00.666841] [<fffffc00080e3720>]
> > call_usermodehelper_exec_async+0xe8/0x148
> > [=A0=A0=A0=A00.666850] [<fffffc0008084a80>] ret_from_fork+0x10/0x50
> >=20
> > This happens on every call to execve. This seems to be the first
> > copy_to_user in
> > create_elf_tables. I didn't get a chance to debug and I'm going out
> > of town
> > all of next week so all I have is the report unfortunately. config
> > attached.
>=20
> That's odd, this should be copying a piece of kernel data (not text)
> to userspace.
>=20
> from fs/binfmt_elf.c
>=20
> =A0 =A0 =A0 =A0 const char *k_platform =3D ELF_PLATFORM;
>=20
> ...
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t len =3D strlen(k_platform) + 1;
> 	=09
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u_platform =3D (elf_addr_t __user *)STACK=
_ALLOC(p, len);
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if (__copy_to_user(u_plat=
form, k_platform, len))
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0r=
eturn -EFAULT;
>=20
> from arch/arm/include/asm/elf.h:
>=20
> #define ELF_PLATFORM_SIZE 8
> #define ELF_PLATFORM=A0=A0=A0=A0(elf_platform)
>=20
> extern char elf_platform[];
>=20
> from arch/arm/kernel/setup.c:
>=20
> char elf_platform[ELF_PLATFORM_SIZE];
> EXPORT_SYMBOL(elf_platform);
>=20
> ...
>=20
> =A0=A0=A0=A0=A0=A0=A0=A0snprintf(elf_platform, ELF_PLATFORM_SIZE, "%s%c",
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0list->elf_name, ENDIAN=
NESS);
>=20
> How does that end up in the .text section of the
> image, instead of in one of the various data sections?
>=20
> What kind of linker oddity is going on with ARM?

I think the crash happened on ARM64, not ARM.

Thanks,

	Ingo
