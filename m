From: Tony Luck <tony.luck@gmail.com>
Date: Wed, 13 Jun 2012 20:50:51 +0000
Subject: Re: [PATCH 09/19 v2] ia64/mm/fault.c: Port OOM changes to ia64_do_page_fault
Message-Id: <CA+8MBb++0hF0bgKHaxkvSd+BsnVGBwvzz=OaFoJj+BpRF6i_sg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333195412-5217-1-git-send-email-consul.kautuk@gmail.com>
In-Reply-To: <1333195412-5217-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Jun 12, 2012 at 8:51 AM, Kautuk Consul <consul.kautuk@gmail.com> wr=
ote:
>> + =A0 =A0 =A0 mask =3D ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 | (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_W=
RITE_BIT));

You added these uses of VM_EXEC_BIT and VM_WRITE_BIT ... but
these macros are not defined until a few lines later in this file.  I moved
them (and the VM_READ_BIT definition) up to just before the
start of ia64_do_page_fault() to fix the compilation errors. No need
to re-submit a fixed patch.

Do you know if the test program mentioned in
d065bd810b6deb67d4897a14bfe21f8eb526ba99:
    - microbenchmark: thread A mmaps a large file and does random read acce=
sses
      to the mmaped area - achieves about 55 iterations/s. Thread B does
      mmap/munmap in a loop at a separate location - achieves 55 iterations=
/s
      before, 15000 iterations/s after.
was posted? I'd like to make sure that ia64 is seeing the benefit.

-Tony
