From: Eric Piel <Eric.Piel@lifl.fr>
Date: Wed, 09 Mar 2005 23:48:58 +0000
Subject: Re: [PATCH] Documentation update about pal_halt_light
Message-Id: <422F8B6A.30103@lifl.fr>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050507040608080501030503"
List-Id: <linux-ia64.vger.kernel.org>
References: <422F1246.80008@lifl.fr>
In-Reply-To: <422F1246.80008@lifl.fr>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050507040608080501030503
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"
Content-Transfer-Encoding: quoted-printable

David Mosberger a =E9crit :
>>>>>>On Wed, 09 Mar 2005 16:12:06 +0100, Eric Piel <Eric.Piel@lifl.fr> sai=
d:
>=20
>=20
>   Eric> Hello, I had to hang around in the code to find this
>   Eric> invaluable option "nohalt". Let's document it!
>=20
>   Eric> That's a trivial documentation update, please apply.
>=20
> Good catch.  I thought it was documented already.  Perhaps it got
> lost.  In any case, I think it would be good to mention why someone
> might want to turn it on.  Perhaps something along the lines of:
>=20
> 	"This increases power-consumption.  On the positive side, it
> 	 reduces interrupt wake-up latency, which may improve
> 	 performance in certain environments such as networked
> 	 servers."
>=20
Yes, the more, the merrier! Here is a new patch with the additional=20
information proposed by David (and a little bit from me).

please discard the previous patch and apply this one,
Eric

Signed-off-by: Eric Piel <eric.piel@lifl.fr>

--------------050507040608080501030503
Content-Type: text/x-patch;
 name="parameter-nohalt-ia64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="parameter-nohalt-ia64.patch"

--- linux-2.6.11/Documentation/kernel-parameters.txt.bak	2005-03-09 15:39:10.348323818 +0100
+++ linux-2.6.11/Documentation/kernel-parameters.txt	2005-03-10 00:41:15.289029890 +0100
@@ -837,6 +837,13 @@
 			instruction doesn't work correctly and not to
 			use it.
 
+	nohalt		[IA-64] Tells the kernel not to use the power saving 
+			function PAL_HALT_LIGHT when idle. This increases 
+			power-consumption. On the positive side, it reduces
+			interrupt wake-up latency, which may improve performance
+			in certain environments such as networked servers or
+			real-time systems.
+
 	noirqdebug	[IA-32] Disables the code which attempts to detect and
 			disable unhandled interrupt sources.
 

--------------050507040608080501030503--
