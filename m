From: Roy Dragseth <Roy.Dragseth@cc.uit.no>
Date: Thu, 03 Nov 2005 08:10:34 +0000
Subject: Re: Probing for physical number of cpus.
Message-Id: <200511030910.34808.Roy.Dragseth@cc.uit.no>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510281318.51532.Roy.Dragseth@cc.uit.no>
In-Reply-To: <200510281318.51532.Roy.Dragseth@cc.uit.no>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Friday 28 October 2005 14:43, Andreas Schwab wrote:
> Roy Dragseth <Roy.Dragseth@cc.uit.no> writes:
> > Do anyone know how to figure out the physical number of cpus in an ia64
> > system?  No, /proc/cpuinfo wont do because the kernel is booted with
> > maxcpus=3D1.
>
> Read and parse the ACPI tables off of /dev/mem, starting with the address
> from /sys/firmware/efi/systab.

Yikes!  Thanks for the answer.  I've been toying around with pmtools/acpidu=
mp=20
which gives me a text dump, but I'm still a bit confused (to say the least).

r.

--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8 Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no
