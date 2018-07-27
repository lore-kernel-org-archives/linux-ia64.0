From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Jul 2018 19:08:40 +0000
Subject: RE: [ia64:noboot 4/4] mm/page_alloc.c:321:14: error: 'PAGES_PER_SECTION' undeclared; did you mean 'U
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7D384548@ORSMSX110.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201807270703.ixR4vo9j%fengguang.wu@intel.com>
In-Reply-To: <201807270703.ixR4vo9j%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>> mm/page_alloc.c:321:14: error: 'PAGES_PER_SECTION' undeclared (first use=
 in this function); did you mean 'USEC_PER_SEC'?

Weird.  I unpacked that config file and tried to reproduce ... but got a cl=
ean build.

Maybe my build flipped some other options because I'm using an ancient comp=
iler?
I noticed this difference at the top of the output when I diffed my .config=
 with the
supplied one:

< CONFIG_GCC_VERSION=80100
---
> CONFIG_GCC_VERSION@304

Mike: Did you see anything like this when you did cross builds?

-Tony


