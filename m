From: Alex Chiang <achiang@hp.com>
Date: Thu, 14 Jan 2010 05:01:42 +0000
Subject: Re: lockdep support caused an MCA
Message-Id: <20100114050142.GE27766@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100111195825.GE10162@ldl.fc.hp.com>
In-Reply-To: <20100111195825.GE10162@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

* Luming Yu <luming.yu@gmail.com>:
> On Tue, Jan 12, 2010 at 9:51 AM, Yu, Luming <luming.yu@intel.com> wrote:
> > Let me check if I can get access to an HP rx8640 to re-spin the patch.
> >
> >
> > -----Original Message-----
> > From: Alex Chiang [mailto:achiang@hp.com]
> > Sent: Tuesday, January 12, 2010 3:58 AM
> > To: Yu, Luming; Luck, Tony
> > Cc: linux-ia64@vger.kernel.org
> > Subject: lockdep support caused an MCA
> >
> > This patch 2f02b4a12b24c9f077c6d739ac23c9b90840ccca:
> >
> > Author: Luming Yu <luming.yu@intel.com> =A02009-12-04 09:14:30
> >
> > =A0 =A0[IA64] lockdep support
> >
> > =A0 =A0Basic functionality for lockdep on ia64.
> >
> > =A0 =A0Known issues:
> > =A0 =A00. dynamic allocate per CPU area in lockdep.
> > =A0 =A01. lock held in leave kernel.
> > =A0 =A02. enabling CONFIG_DEBUG_LOCKDEP triggers the lockdep warning.
> > =A0 =A03. Need to implement save_stack functions
> > =A0 =A04. Replace some cpp macros with inline functions
> > =A0 =A05. Add nmi_enter/nmi_exit
> >
> > =A0 =A0Signed-off-by: Bob Picco <bob.picco@hp.com>
> > =A0 =A0Signed-off-by: Yu Luming <luming.yu@intel.com>
> > =A0 =A0Signed-off-by: Tony Luck <tony.luck@intel.com>
> >
> > causes a very early MCA on an HP rx8640.
> >
> > Unfortunately, even with early_printk turned on, the machine
> > encounters the MCA and reboots before any output occurs, so I
> > don't have any further information.
> >
> > I haven't done any other triage on this as the patch has already
> > been dropped from Tony's tree, but I'd be happy to test the next
> > go-around.
>=20
> I have managed to get the patch run on a HP rx8640 system with
> latest next tree + ia64-lockdep patch. The following is the part of
> boot log with lockdep footprints..The interesting thing is
> lockdep code seems to have detected possible recursive locking
> with the kernel on the platform.

How many cells was your system? Mine was 2 cells (for a total of
16 CPUs). I just mention this because booting on a 1 cell config
is quite different from a multi-cell config.

Thanks for getting it going though.

/ac

