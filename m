From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Mon, 04 Dec 2017 14:46:58 +0000
Subject: Re: [PATCH] acpi, numa, ia64: Parse all entries of SRAT memory affinity table
Message-Id: <7029225.zYlq9pRjNx@aspire.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171115172902.20083-1-ganapatrao.kulkarni@cavium.com> <CAJZ5v0in=eK9RT5ODGYp8FEggCOKeRdxKdD3JkiAoxqTuveuWA@mail.gmail.com> <CAKTKpr4n2154Ep1541mjzFntyWxVtMWvxJf87UYQT-1XP37CZA@mail.gmail.com>
In-Reply-To: <CAKTKpr4n2154Ep1541mjzFntyWxVtMWvxJf87UYQT-1XP37CZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ganapatrao Kulkarni <gklkml16@gmail.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "lenb@kernel.org" <lenb@kernel.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "jnair@caviumnetworks.com" <jnair@caviumnetworks.com>, "gpkulkarni@gmail.com" <gpkulkarni@gmail.com>, "Robert.Richter@cavium.com" <Robert.Richter@cavium.com>

On Tuesday, November 21, 2017 6:10:53 PM CET Ganapatrao Kulkarni wrote:
> On Tue, Nov 21, 2017 at 6:22 PM, Rafael J. Wysocki <rafael@kernel.org> wrote:
> > On Tue, Nov 21, 2017 at 5:16 AM, Ganapatrao Kulkarni <gklkml16@gmail.com> wrote:
> >> On Thu, Nov 16, 2017 at 12:16 AM, Luck, Tony <tony.luck@intel.com> wrote:
> >>>> This check is already added in x86 and extending same to ia64.
> >>>
> >>> Looks OK.
> >>>
> >>> Acked-by: Tony Luck <tony.luck@intel.com>
> >>
> >> thanks Tony.
> >>
> >> ACPI Maintainers,
> >> any comments on this patch? i can send rebasing to 4.15-rc1?
> >
> > I've queued it up already.
> 
> thanks Rafael.
> >
> > Is there any urgent need for that to go into 4.15?
> 
> not really.

OK, applied and queued up for 4.16.

Thanks,
Rafael

