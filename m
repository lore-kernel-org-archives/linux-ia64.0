From: Roy Dragseth <royd@cc.uit.no>
Date: Wed, 08 Jan 2003 22:08:51 +0000
Subject: Re: [Linux-ia64] disabling nics in efi.
Message-Id: <marc-linux-ia64-105590709805649@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805644@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805644@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wednesday 08 January 2003 22:52, Alex Williamson wrote:
>    The EFI driver has nothing to do with whether the NIC shows up
> to the OS.  It only makes it unavailble from EFI, the hardware is
> still there.  I don't know of any way to make the NICs not show up
> other than not loading the module.

So, I was indeed missing the point.

The only viable path seems to be preventing the kernel to probe the interfa=
ces=20
using the reserve boot option.  If I only could figure out how to compute t=
he=20
right addresses...

r.

--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8, Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no


