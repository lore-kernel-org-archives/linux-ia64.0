From: Jes Sorensen <jes@sgi.com>
Date: Fri, 01 Dec 2006 16:36:19 +0000
Subject: Re: [PATCH] Add support for type argument in PAL_GET_PSTATE
Message-Id: <yq0bqmnvaik.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061101103500.A16140@unix-os.sc.intel.com>
In-Reply-To: <20061101103500.A16140@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> "Venkatesh" =3D Venkatesh Pallipadi <venkatesh.pallipadi@intel.com> w=
rites:

Venkatesh> PAL_GET_PSTATE accepts a type argument to return different
Venkatesh> kinds of frequency information.  Refer: Intel
Venkatesh> Itanium=81=AEArchitecture Software Developer's Manual -
Venkatesh> Volume 2: System Architecture, Revision 2.2
Venkatesh> (http://developer.intel.com/design/itanium/manuals/245318.htm)

....

Venkatesh> @@ -79,6 +79,11 @@
Venkatesh>  #define PAL_GET_PSTATE		262	/* get the current P-state */
Venkatesh>  #define PAL_SET_PSTATE		263	/* set the P-state */
Venkatesh> =20
Venkatesh> +#define PAL_GET_PSTATE_TYPE_LASTSET	(0)
Venkatesh> +#define PAL_GET_PSTATE_TYPE_AVGANDRESET	(1)
Venkatesh> +#define PAL_GET_PSTATE_TYPE_AVGNORESET	(2)
Venkatesh> +#define PAL_GET_PSTATE_TYPE_INSTANT	(3)
Venkatesh> +

Hi Venkatesh,

Please respect the previous formatting of the file and not add
pointless parenthesises around the constants like that.

Cheers,
Jes
