From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 13 Oct 2003 09:00:47 +0000
Subject: Re: [PATCH] select EFI partition support by default
Message-Id: <marc-linux-ia64-106603589607453@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106588409310269@msgid-missing>
In-Reply-To: <marc-linux-ia64-106588409310269@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sat, Oct 11, 2003 at 11:11:34AM -0500, Matt Domsch wrote:
> > +=A0=A0=A0=A0=A0=A0 bool "EFI GUID Partition support" if PARTITION_ADVA=
NCED
> > +=A0=A0=A0=A0=A0=A0 default y if !PARTITION_ADVANCED && IA64
>=20
> Can we make CONFIG_LBD force on CONFIG_EFI_PARTITION too then?

I know the LBD backport is used with SGI disklabels in production
enviroments.  In fact that's the only production use I know of at all...

