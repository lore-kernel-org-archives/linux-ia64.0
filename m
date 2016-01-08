From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 08 Jan 2016 10:14:48 +0000
Subject: Re: [PATCH 3/3] checkpatch: add virt barriers
Message-Id: <20160108121352-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451907395-15978-1-git-send-email-mst@redhat.com>
	<1451907395-15978-4-git-send-email-mst@redhat.com>
	<1451926073.4334.90.camel@perches.com>
	<20160104230528-mutt-send-email-mst@redhat.com>
	<1451945497.4334.107.camel@perches.com>
In-Reply-To: <1451945497.4334.107.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Joe Perches <joe@perches.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, Tony Lindgren <tony@atomide.com>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, "Cc : Andy Whitcroft" <apw@canonical.com>, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew

On Mon, Jan 04, 2016 at 02:11:37PM -0800, Joe Perches wrote:
> On Mon, 2016-01-04 at 23:07 +0200, Michael S. Tsirkin wrote:
> > On Mon, Jan 04, 2016 at 08:47:53AM -0800, Joe Perches wrote:
> > > On Mon, 2016-01-04 at 13:37 +0200, Michael S. Tsirkin wrote:
> > > > Add virt_ barriers to list of barriers to check for
> > > > presence of a comment.
> > >=20
> > > Are these virt_ barriers used anywhere?
> > >=20
> > > I see some virtio_ barrier like uses.
> >=20
> > They will be :) They are added and used by patchset
> > 	=A0=A0=A0=A0=A0=A0=A0=A0arch: barrier cleanup + barriers for virt
> >=20
> > See
> > http://article.gmane.org/gmane.linux.kernel.virtualization/26555
>=20
> Ah, OK, thanks.
>=20
> Are the virtio_ barriers going away?
> If not, maybe those should be added too.

I don't mind. I'll queue a patch like that.


--=20
MST
