From: Andreas Schwab <schwab@suse.de>
Date: Fri, 28 Oct 2005 12:43:50 +0000
Subject: Re: Probing for physical number of cpus.
Message-Id: <jeek65n75l.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510281318.51532.Roy.Dragseth@cc.uit.no>
In-Reply-To: <200510281318.51532.Roy.Dragseth@cc.uit.no>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Roy Dragseth <Roy.Dragseth@cc.uit.no> writes:

> Do anyone know how to figure out the physical number of cpus in an ia64=20
> system?  No, /proc/cpuinfo wont do because the kernel is booted with=20
> maxcpus=3D1.

Read and parse the ACPI tables off of /dev/mem, starting with the address
from /sys/firmware/efi/systab.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
