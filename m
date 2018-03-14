From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Wed, 14 Mar 2018 18:17:07 +0000
Subject: Re: [PATCH] PCI/MSI: Don't set up INTx if MSI or MSI-X is enabled
Message-Id: <CAHp75VdZSZ2srwuWREj0=NrpmfxKmjG5KmPW2jN9+mZ025j4nQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <152097754955.241946.9551793957889760940.stgit@bhelgaas-glaptop.roam.corp.google.com>
 <CAHp75Vfp_uwSLe_ENnr=azJGrMoR6DuvGSCi5DSeq6=B-ghAGg@mail.gmail.com> <20180314174946.GB179719@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20180314174946.GB179719@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: linux-pci@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, David Howells <dhowells@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Cris <linux-cris-kernel@axis.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-am33-list@redhat.com

On Wed, Mar 14, 2018 at 7:49 PM, Bjorn Helgaas <helgaas@kernel.org> wrote:
> On Wed, Mar 14, 2018 at 06:31:38PM +0200, Andy Shevchenko wrote:
>> On Tue, Mar 13, 2018 at 11:45 PM, Bjorn Helgaas <helgaas@kernel.org> wrote:

>> > If a device already has MSI or MSI-X enabled, there's no need to set up its
>> > legacy INTx interrupt.
>>
>> Just point to the actual behaviour of this.
>
> By "point to the actual behaviour", do you mean adding something to
> the changelog along the lines of the following?
>
>   If MSI or MSI-X is enabled, the device uses that.  It uses INTx only
>   if both MSI and MSI-X are disabled (see PCIe r4.0, sec 7.7.1.2).
>
> I did add that because I think that spec reference is useful.  If you
> have something else in mind, maybe an example would help me
> understand.

I meant that the behaviour now is changed from
 check MSI only case
to
 check MSI _or MSI-x_ case

Not all code paths may survive that.

>> In some cases code in question has to distinguish between MSI and
>> MSI-x.  So, this or similar changes has to be done with keeping
>> above in mind.
>>
>> (Existing example is Thunderbolt driver)
>
> Sorry, I didn't get your point here.  Certainly some code needs to
> distinguish between MSI and MSI-X, but I don't think that's the case
> here.  I'm not proposing to change Thunderbolt; I do see that it uses
> dev->msix_enabled (but not dev->msi_enabled), and it doesn't look like
> using pci_dev_msi_enabled() there would be appropriate.

Exactly, that's why I pointed on above.

-- 
With Best Regards,
Andy Shevchenko
