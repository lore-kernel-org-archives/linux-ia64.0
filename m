From: Younggyun Koh <young@cc.gatech.edu>
Date: Wed, 26 May 2004 12:46:19 +0000
Subject: Re: Installing kernel 2.6.6 on hp zx6000 (fwd)
Message-Id: <Pine.GSO.4.58.0405260843090.12310@tokyo.cc.gatech.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
In-Reply-To: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > 3. i got the link error when i build the kernel
> >
> > bash-2.05$ make CROSS_COMPILE=/opt/gcc-3.3.3/usr/local/bin/
>
> Can you add "V=1" parameter so we can see the commands?

        /opt/gcc-3.3.3/usr/local/bin/ld  -static -T
arch/ia64/kernel/vmlinux.lds.s arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o   init/built-in.o
--start-group  usr/built-in.o  arch/ia64/kernel/built-in.o  arch/ia64/mm/built-in.o
arch/ia64/ia32/built-in.o  arch/ia64/dig/built-in.o  kernel/built-in.o  mm/built-in.o
fs/built-in.o ipc/built-in.o  security/built-in.o  crypto/built-in.o  lib/lib.a
arch/ia64/lib/lib.a  lib/built-in.o  arch/ia64/lib/built-in.o  drivers/built-in.o
sound/built-in.o  arch/ia64/pci/built-in.o  arch/ia64/hp/common/built-in.o
arch/ia64/hp/zx1/built-in.o arch/ia64/hp/sim/built-in.o  arch/ia64/sn/built-in.o  net/built-in.o
--end-group  -o .tmp_vmlinux1
/opt/gcc-3.3.3/usr/local/bin/ld: final link failed: File truncated
make: *** [.tmp_vmlinux1] Error 1

thank you,

			-Younggyun Koh (young@cc.gatech.edu)

> > 3. i got the link error when i build the kernel
> >
> > bash-2.05$ make CROSS_COMPILE=/opt/gcc-3.3.3/usr/local/bin/
>
> Can you add "V=1" parameter so we can see the commands?
>
> thanks,
> grant
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
