From: Kautuk Consul <consul.kautuk@gmail.com>
Date: Thu, 14 Jun 2012 16:29:20 +0000
Subject: Re: [PATCH 09/19 v2] ia64/mm/fault.c: Port OOM changes to ia64_do_page_fault
Message-Id: <CAFPAmTTKNpuoZV5qxoTBkRFsSkzFfQjB7RyCAyABxB=OjXK7ZQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333195412-5217-1-git-send-email-consul.kautuk@gmail.com>
In-Reply-To: <1333195412-5217-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, Jun 14, 2012 at 2:20 AM, Tony Luck <tony.luck@gmail.com> wrote:
> On Tue, Jun 12, 2012 at 8:51 AM, Kautuk Consul <consul.kautuk@gmail.com> =
wrote:
>>> + =A0 =A0 =A0 mask =3D ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 | (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_=
WRITE_BIT));
>
> You added these uses of VM_EXEC_BIT and VM_WRITE_BIT ... but
> these macros are not defined until a few lines later in this file. =A0I m=
oved
> them (and the VM_READ_BIT definition) up to just before the
> start of ia64_do_page_fault() to fix the compilation errors. No need
> to re-submit a fixed patch.
>

Thanks for the help, Tony !
Terribly sorry for my mistakes as I don't have an ia64 system.

> Do you know if the test program mentioned in
> d065bd810b6deb67d4897a14bfe21f8eb526ba99:
> =A0 =A0- microbenchmark: thread A mmaps a large file and does random read=
 accesses
> =A0 =A0 =A0to the mmaped area - achieves about 55 iterations/s. Thread B =
does
> =A0 =A0 =A0mmap/munmap in a loop at a separate location - achieves 55 ite=
rations/s
> =A0 =A0 =A0before, 15000 iterations/s after.
> was posted? I'd like to make sure that ia64 is seeing the benefit.

I couldn't find any test-case for that, but I tested in for ARM and
MIPS where I was seeing
hangs and livelocks.
Maybe you can try my test-case at https://lkml.org/lkml/2012/3/31/90 ?

>
> -Tony
