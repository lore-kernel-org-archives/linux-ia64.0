From: Eugene Syromiatnikov <esyr@redhat.com>
Date: Thu, 11 Oct 2018 15:06:58 +0000
Subject: Re: [PATCH v3 7/7] ia64: wire up system calls
Message-Id: <20181011150654.GB22118@asgard.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1539231895-4118-1-git-send-email-firoz.khan@linaro.org>
 <1539231895-4118-8-git-send-email-firoz.khan@linaro.org>
 <CAK8P3a3OS-aKFrb5g1i00-+G1+uZqEkH0C1FX08tTx=-89-hfQ@mail.gmail.com>
In-Reply-To: <CAK8P3a3OS-aKFrb5g1i00-+G1+uZqEkH0C1FX08tTx=-89-hfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Firoz Khan <firoz.khan@linaro.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, gregkh <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

On Thu, Oct 11, 2018 at 09:24:43AM +0200, Arnd Bergmann wrote:
> On Thu, Oct 11, 2018 at 6:26 AM Firoz Khan <firoz.khan@linaro.org> wrote:
> > +# perf_event_open requires an architecture specific implementation
> > +326    common  perf_event_open                 sys_perf_event_open
[...]
> 
> I don't think that's correct for these two. perf_event_open() of
> course requires 'perf' support that ia64 does not have

That's actuallt quite funny, given the fact that IA-64 has perfmonctl()
which likely was the precursor of current perf infractructure.

> > +# pkey_mprotect requires an architecture specific implementation
> > +328    common  pkey_mprotect                   sys_pkey_mprotect
> > +# pkey_alloc requires an architecture specific implementation
> > +329    common  pkey_alloc                      sys_pkey_alloc
> > +# pkey_free requires an architecture specific implementation
> > +330    common  pkey_free                       sys_pkey_free
> 
> One comment for all pkey calls would be sufficient. More importantly
> it requires hardware support that ia64 does not have AFAICT.

Except it has[1].

[1] https://www.thailand.intel.com/content/dam/www/public/us/en/documents/manuals/itanium-architecture-software-developer-rev-2-3-vol-2-manual.pdf#pagex
