From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 17 Jul 2015 17:50:05 +0000
Subject: Re: [PATCH 1/3] x86, irq: Rename VECTOR_UNDEFINED and VECTOR_RETRIGGERED to IRQ_*
Message-Id: <CAErSpo6HFN1i2cMwrLyFoYGrvaX-QFeVT_bJyRo9wpFLwma49g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150712215559.7166.33068.stgit@bhelgaas-glaptop2.roam.corp.google.com>
 <20150712220154.7166.48327.stgit@bhelgaas-glaptop2.roam.corp.google.com> <alpine.DEB.2.11.1507171558010.18576@nanos>
In-Reply-To: <alpine.DEB.2.11.1507171558010.18576@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, linux-am33-list@redhat.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, adi-buildroot-devel@lists.sourceforge.net, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, "x86@kernel.org" <x86@kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Fri, Jul 17, 2015 at 9:06 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Sun, 12 Jul 2015, Bjorn Helgaas wrote:
>
>> The per-cpu vector_irq[] table is indexed by CPU vector numbers, and each
>> entry contains an IRQ number.
>>
>> Rename the special values VECTOR_UNDEFINED and VECTOR_RETRIGGERED to
>> IRQ_UNDEFINED and IRQ_RETRIGGERED to indicate that they are in the IRQ
>> number space, not the CPU vector number space.
>
> Makes some sense, but OTOH vector_irq actually reflects the vector
> state not the irq number state. The fact that we store the Linux irq
> number in vector_irq is just an implementation detail.
>
> VECTOR_UNDEFINED is certainly a misnomer; that should be VECTOR_UNUSED
>
> VECTOR_RETRIGGERED is pretty accurate. In the case we retrigger an
> interrupt, we merily use the Linux irq number to figure out which
> vector to kick. And after we retriggered it, we lose the association
> to the Linux irq number completely.
>
> That said, I'm working on storing the irq descriptor pointer in
> vector_irq instead of the irq number, which has the advantage that we
> avoid the lookup of the irq descriptor in the interrupt hotpath.

OK, I'll abandon this.  Thanks for taking a look!

Bjorn
