From: =?ISO-8859-1?Q?=C9meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Mon, 27 Jan 2014 20:53:56 +0000
Subject: Re: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <CAA9xbM4yjX0vQLmcqUQxYRedwFFwMckAWuSGfYfQVgBUBJx_Kw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> It seems that newer gcc (4.8.2) works again (see the Mikael/Mikulas
> thread on "ski" on this mailing list.  I also managed to build a kernel
> with gcc 4.8.2 and boot it on my rx2600.

Tony, is GDB working correctly with your gcc 4.8.2-compiled kernel?
Indeed, one noticeable evidence of optimization's breakage is GDB
stopping with SIGTRAP at address 0 as soon as GDB's run command is
executed [1].

     =C9meric


[1] http://bugs.debian.org/cgi-bin/bugreport.cgi?bugi1576
