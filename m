From: Gerald Pfeifer <gp@suse.de>
Date: Tue, 02 Nov 2004 08:48:29 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <Pine.LNX.4.61.0411020937510.24640@lifschitz.suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="168476160-968527680-1099380432=:24640"
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--168476160-968527680-1099380432=:24640
Content-Type: TEXT/PLAIN; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Mon, 1 Nov 2004, Matthew Wilcox wrote:
> Doesn't sound like a great idea.  HP's already shipping 128-way Superdome
> IA-64 systems, and they'll want to be set up rather differently from the
> Altix systems.  I think this code needs to be autotuning so it doesn't
> need to be touched whenever a vendor releases a new configuration (I
> think I heard that NASA's Altixes had a custom CPU brick with twice the
> CPUs in it?)

Yup.  Though that new brick is not specific to NASA's new Columbia system.

http://www.sgi.com/company_info/newsroom/press_releases/2004/october/altix_=
bx2.html

| SGI Doubles Density of High-End Altix Server
|
| New Altix 3700 Bx2 Ratchets Up Performance and Cost-Efficiency with=20
| Twice the Bandwidth, Half the Footprint of Flagship System=20
|
| MOUNTAIN VIEW, Calif., (October 28, 2004) [...] Silicon Graphics today=20
| unveiled a new version of its SGI=AE Altix=AE 3700 system that delivers=20
| twice the bandwidth and processor density of its flagship high-end=20
| model.

Gerald (not working for SGI ;-)
--168476160-968527680-1099380432=:24640--
