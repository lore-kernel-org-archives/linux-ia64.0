From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 09 Jun 2004 21:52:37 +0000
Subject: Re: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <1086817957.4288.108.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
	 <1086805676.4288.16.camel@tdi> <20040609130001.37a88da1.davem@redhat.com>
	 <1086812976.4288.50.camel@tdi> <20040609132937.68866dfc.davem@redhat.com>
	 <20040609213338.GI11490@sunbeam.de.gnumonks.org>
In-Reply-To: <20040609213338.GI11490@sunbeam.de.gnumonks.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Harald Welte <laforge@gnumonks.org>
Cc: "David S. Miller" <davem@redhat.com>, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 2004-06-09 at 15:33, Harald Welte wrote:
> On Wed, Jun 09, 2004 at 01:29:37PM -0700, David S. Miller wrote:
> >=20
> > Right.  I distinctly remember a similar fix being needed to
> > ip_tables.c many months ago, a search though the change history
> > for that file might prove profitable :-)
>=20
> Or alternatively look into the netfilter bugzilla at:
>=20
> https://bugzilla.netfilter.org/cgi-bin/bugzilla/show_bug.cgi?id=84
>=20
> If somebody wants to prepare a trivial merge of that fix with arptables
> - it should be extermely straight forward ;)

   That change is probably appropriate, but IIRC, that's not the
alignment problem I saw, and that one certainly wouldn't have been fixed
by a change to the arpt_arp structure.  Looking at the code snippet
again:

/* Look for ifname matches; this should unroll nicely. */
for (i =3D 0, ret =3D 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
        ret |=3D (((const unsigned long *)indev)[i]
                ^ ((const unsigned long *)arpinfo->iniface)[i])
                & ((const unsigned long *)arpinfo->iniface_mask)[i];
}

The alignment problem I remember was with iniface and iniface_mask.  If
we can't change the structure alignment, the easiest fix is to change
the stride length to something appropriate for the arch or maybe just a
least common demoninator.  Maybe someone is smart enough to get the
preprocessor to figure this out automatically...  dunno if that's
possible.

   While we're on this little piece of code, there's another bug here.=20
ret is defined as an int in arp_packet_match() so we're losing the upper
half of the result anyway.  ip_packet_match() appears to already have
this correct.  At a minimum, I think we need the trivial patch below.=20
Thanks,

	Alex

=3D=3D=3D net/ipv4/netfilter/arp_tables.c 1.13 vs edited =3D=3D--- 1.13/net=
/ipv4/netfilter/arp_tables.c	Sun Jun  6 21:15:04 2004
+++ edited/net/ipv4/netfilter/arp_tables.c	Wed Jun  9 15:38:16 2004
@@ -106,7 +106,8 @@
 	char *arpptr =3D (char *)(arphdr + 1);
 	char *src_devaddr, *tgt_devaddr;
 	u32 *src_ipaddr, *tgt_ipaddr;
-	int i, ret;
+	int i;
+	unsigned long ret;
=20
 #define FWINV(bool,invflg) ((bool) ^ !!(arpinfo->invflags & invflg))
=20



