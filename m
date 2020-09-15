From: Masahiro Yamada <masahiroy@kernel.org>
Date: Tue, 15 Sep 2020 06:48:35 +0000
Subject: Re: vmlinux link failure on ia64 with zstd
Message-Id: <CAK7LNAToB3n9Y9OPXR55VKbDAkYgm1kUDO8gUu0Ak_+=6AhzCw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <f0a93b2d435252b3878ce821142677754f5e434c.camel@decadent.org.uk> <6A76267A-6B60-4428-94DF-E05706EB85FB@fb.com>
In-Reply-To: <6A76267A-6B60-4428-94DF-E05706EB85FB@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Nick Terrell <terrelln@fb.com>
Cc: Ben Hutchings <ben@decadent.org.uk>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>

On Tue, Sep 15, 2020 at 4:12 AM Nick Terrell <terrelln@fb.com> wrote:
>
>
>
> > On Sep 13, 2020, at 12:51 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> >
> > Enabling CONFIG_RD_ZSTD (which is enabled by default) resulted in a
> > link failure on ia64:
> >
> > + ld -r -o vmlinux.o --whole-archive arch/ia64/kernel/head.o init/built-in.a usr/built-in.a arch/ia64/kernel/built-in.a arch/ia64/mm/built-in.a kernel/built-in.a certs/built-in.a mm/built-in.a fs/built-in.a ipc/built-in.a security/built-in.a crypto/built-in.a block/built-in.a lib/built-in.a arch/ia64/lib/built-in.a lib/lib.a arch/ia64/lib/lib.a drivers/built-in.a sound/built-in.a net/built-in.a virt/built-in.a arch/ia64/pci/built-in.a arch/ia64/hp/common/built-in.a --no-whole-archive --start-group --end-group
> > ld: lib/zstd/entropy_common.o: linking constant-gp files with non-constant-gp files
> > ld: failed to merge target specific data of file lib/zstd/entropy_common.o
> > ld: lib/zstd/fse_decompress.o: linking constant-gp files with non-constant-gp files
> > ld: failed to merge target specific data of file lib/zstd/fse_decompress.o
> > ld: lib/zstd/zstd_common.o: linking constant-gp files with non-constant-gp files
> > ld: failed to merge target specific data of file lib/zstd/zstd_common.o
>
> I’ve never seen anything like this error before. I did some searching, and found that it may show up if an object file is empty.
>
> These three files are all included in both the zstd_compress and the zstd_decompress modules. We used to exclude these 3 files from the zstd_decompress module when both modules are built-in. But then commit dc35da16a2e2 [0] removed that, because Kbuild is supposed to handle that case.
>
> If you revert commit dc35da16a2e2 [0] does that fix the issue? I’m attempting to build with IA64, and I’ll let you know if I am able to reproduce the issue and test if this fixes it.
>
> CC: Masahiro Yamada <yamada.masahiro@socionext.com> author of the commit and the linux-kbuild mailing list.
>
> [0] https://github.com/torvalds/linux/commit/dc35da16a2e23db04822f0129cd5b28b7b0e72b4


dc35da16a2e2 is more than two years old (i.e. v4.17)

Are we discussing a long-standing issue
or something that arose recently?




> Best,
> Nick
>
> > This is seen on Debian unstable, with gcc 10.2 and binutils 2.35.  A
> > full build log is available at:
> > https://buildd.debian.org/status/fetch.php?pkg=linux&arch=ia64&ver=5.9~rc4-1~exp1&stamp=1599955166&raw=1
> >
> > Ben.
> >
> > --
> > Ben Hutchings
> > Humour is the best antidote to reality.
> >
>


-- 
Best Regards
Masahiro Yamada
