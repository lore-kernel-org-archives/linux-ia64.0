From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Tue, 06 Jun 2006 09:47:42 +0000
Subject: RE: [RFC 1/2] Xen/ia64 modified files
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD8094E7D43@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1149275354.5999.83.camel@lappy>
In-Reply-To: <1149275354.5999.83.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>From: Jes Sorensen
>Sent: 2006=C4=EA6=D4=C26=C8=D5 17:15
>
>>>>>> "Alex" =3D Alex Williamson <alex.williamson@hp.com> writes:
>
>Alex>    This patch includes only the modifications to existing
>Alex> Linux/ia64 files to support both privileged and un-privileged
>Alex> guests on Xen/ia64.
>
>- In general I don't like this CONFIG_XEN being added everywhere. It
>  would be much nicer if we could seperate the majority of the Xen
>  code into a seperate file that is only compiled in when enabled.
>- In many cases expanding and using the machvec table would reduce
>the
>  ugliness of the patches. For instance in the dma mapping code,
>  simply define a set of Xen specific functions that do all the magic
>  stuff nobody else cares about.

Hi, Jes,
	Thanks for careful review. I agree that xen should be introduced=20
as some type of new 'box' as others, like current sn/hp/dig under=20
arch/ia64. That does save many ugly checks for is_running_on_xen=20
scattered in common code. Future it would be even worse. Actually=20
that's the way how xen/x86 has already done currently, where=20
mach-xen is introduced under arch/i386 and thus the hierarchy is=20
much cleaner. IMO, that's one of the outstanding gaps between=20
xen/x86 and xen/ia64, and time for change now. :-)

Thanks,
Kevin
