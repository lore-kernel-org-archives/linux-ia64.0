From: Michel =?ISO-8859-1?Q?D=E4nzer?= <michel@daenzer.net>
Date: Tue, 17 Feb 2004 23:44:16 +0000
Subject: Re: radeon warning on 64-bit platforms
Message-Id: <1077061456.16774.19.camel@thor.asgaard.local>
List-Id: <linux-ia64.vger.kernel.org>
References: <16434.35199.597235.894615@napali.hpl.hp.com>
	 <1077054385.2714.72.camel@thor.asgaard.local>
	 <16434.36137.623311.751484@napali.hpl.hp.com>
	 <1077055209.2712.80.camel@thor.asgaard.local>
	 <16434.37025.840577.826949@napali.hpl.hp.com>
	 <1077058106.2713.88.camel@thor.asgaard.local>
	 <16434.41884.249541.156083@napali.hpl.hp.com>
In-Reply-To: <16434.41884.249541.156083@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: davidm@hpl.hp.com
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


David,


looks good to me, except for a detail:

> +		 * Michael D=C3=A4nzer, the ioctl() is only used on embedded platforms=
, so not
                     ^^^^^^^
That's not quite my first name. :)


I'd appreciate a heads up when this (or whatever becomes of it) goes in
so I can apply it to DRI CVS as well. On the other hand, I'll probably
see it at the latest when Ben merges it into his tree. :)


--=20
Earthling Michel D=C3=A4nzer      |     Debian (powerpc), X and DRI develop=
er
Libre software enthusiast    |   http://svcs.affero.net/rm.php?r=DAenzer

