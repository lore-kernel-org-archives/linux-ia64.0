From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 16 Sep 2020 07:40:47 +0000
Subject: Re: [PATCH v3 1/3] mm: replace memmap_context by meminit_context
Message-Id: <20200916074047.GA189144@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200915121541.GD4649@dhcp22.suse.cz>
 <20200915132624.9723-1-ldufour@linux.ibm.com>
 <20200916063325.GK142621@kroah.com>
 <0b3f2eb1-0efa-a491-c509-d16a7e18d8e8@linux.ibm.com>
In-Reply-To: <0b3f2eb1-0efa-a491-c509-d16a7e18d8e8@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>, mhocko@suse.com, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, Sep 16, 2020 at 09:29:22AM +0200, Laurent Dufour wrote:
> Le 16/09/2020 =E0 08:33, Greg Kroah-Hartman a =E9crit=A0:
> > On Tue, Sep 15, 2020 at 03:26:24PM +0200, Laurent Dufour wrote:
> > > The memmap_context enum is used to detect whether a memory operation =
is due
> > > to a hot-add operation or happening at boot time.
> > >=20
> > > Make it general to the hotplug operation and rename it as meminit_con=
text.
> > >=20
> > > There is no functional change introduced by this patch
> > >=20
> > > Suggested-by: David Hildenbrand <david@redhat.com>
> > > Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> > > ---
> > >   arch/ia64/mm/init.c    |  6 +++---
> > >   include/linux/mm.h     |  2 +-
> > >   include/linux/mmzone.h | 11 ++++++++---
> > >   mm/memory_hotplug.c    |  2 +-
> > >   mm/page_alloc.c        | 10 +++++-----
> > >   5 files changed, 18 insertions(+), 13 deletions(-)
> >=20
> > <formletter>
> >=20
> > This is not the correct way to submit patches for inclusion in the
> > stable kernel tree.  Please read:
> >      https://www.kernel.org/doc/html/latest/process/stable-kernel-rules=
.html
> > for how to do this properly.
> >=20
> > </formletter>
>=20
> Hi Greg,
>=20
> I'm sorry, I read that document few days ago before sending the series and
> again this morning, but I can't figure out what I missed (following option
> 1).
>=20
> Should the "Cc: stable@vger.kernel.org" tag be on each patch of the series
> even if the whole series has been sent to stable ?

That should be on any patch you expect to show up in a stable kernel
release.

> Should the whole series sent again (v4) instead of sending a fix as a rep=
ly to ?

It's up to the maintainer what they want, but as it is, this patch is
not going to end up in stable kernel release (which it looks like is the
right thing to do...)

thanks,

greg k-h
