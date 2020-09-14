From: Michal Hocko <mhocko@suse.com>
Date: Mon, 14 Sep 2020 08:59:53 +0000
Subject: Re: [PATCH 1/3] mm: replace memmap_context by memplug_context
Message-Id: <20200914085953.GD16999@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-2-ldufour@linux.ibm.com>
 <20200914084904.GA16999@dhcp22.suse.cz>
 <d3843235-2e02-a4ad-494c-20222a7e3b45@linux.ibm.com>
In-Reply-To: <d3843235-2e02-a4ad-494c-20222a7e3b45@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 14-09-20 10:51:06, Laurent Dufour wrote:
> Le 14/09/2020 =E0 10:49, Michal Hocko a =E9crit=A0:
[...]
> > /*
> >   * Memory initialization context, use to differentiate memory added by
> >   * the platform statically or via memory hotplug interface.
> >   */
> > enum meminit_context {
> > 	MEMINIT_EARLY,
> > 	MEMINIT_HOTPLUG
> > }
> >=20
>=20
> Sounds good too.
> What about its definition's place, in include/mm/zone.h as David suggeste=
d ?

Yes. This shouldn't be in the hotplug proper.

--=20
Michal Hocko
SUSE Labs
