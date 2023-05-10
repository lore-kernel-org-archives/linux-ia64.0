From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 10 May 2023 07:13:50 +0000
Subject: Re: [PATCH 05/23] m68k: allow pte_offset_map[_lock]() to fail
Message-Id: <CAMuHMdWb0SrEs=cDzKW1Ai2UywnnpZip4pk9mOkiVGivPpj8sg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com> <237c8410-ce61-94c-4260-7318ad6a4f3@google.com>
In-Reply-To: <237c8410-ce61-94c-4260-7318ad6a4f3@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Claudio Imbrenda <imbrenda@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

Thanks for your patch!

On Wed, May 10, 2023 at 6:48=E2=80=AFAM Hugh Dickins <hughd@google.com> wro=
te:
> In rare transient cases, not yet made possible, pte_offset_map() and
> pte_offset_map_lock() may not find a page table: handle appropriately.
>
> Restructure cf_tlb_miss() with a pte_unmap() (previously omitted)
> at label out, followed by one local_irq_restore() for all.

That's a bug fix, which should be a separate patch?

>
> Signed-off-by: Hugh Dickins <hughd@google.com>


> --- a/arch/m68k/include/asm/mmu_context.h
> +++ b/arch/m68k/include/asm/mmu_context.h
> @@ -99,7 +99,7 @@ static inline void load_ksp_mmu(struct task_struct *tas=
k)
>         p4d_t *p4d;
>         pud_t *pud;
>         pmd_t *pmd;
> -       pte_t *pte;
> +       pte_t *pte =3D NULL;
>         unsigned long mmuar;
>
>         local_irq_save(flags);
> @@ -139,7 +139,7 @@ static inline void load_ksp_mmu(struct task_struct *t=
ask)
>
>         pte =3D (mmuar >=3D PAGE_OFFSET) ? pte_offset_kernel(pmd, mmuar)
>                                      : pte_offset_map(pmd, mmuar);
> -       if (pte_none(*pte) || !pte_present(*pte))
> +       if (!pte || pte_none(*pte) || !pte_present(*pte))
>                 goto bug;

If the absence of a pte is to become a non-abnormal case, it should
probably jump to "end" instead, to avoid spamming the kernel log.

>
>         set_pte(pte, pte_mkyoung(*pte));
> @@ -161,6 +161,8 @@ static inline void load_ksp_mmu(struct task_struct *t=
ask)
>  bug:
>         pr_info("ksp load failed: mm=3D0x%p ksp=3D0x08%lx\n", mm, mmuar);
>  end:
> +       if (pte && mmuar < PAGE_OFFSET)
> +               pte_unmap(pte);

Is this also a bugfix, not mentioned in the patch description?

>         local_irq_restore(flags);
>  }
>

Gr{oetje,eeting}s,

                        Geert

--=20
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
