From: Dmitry Torokhov <dtor_core@ameritech.net>
Date: Mon, 27 Sep 2004 18:09:17 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface support
Message-Id: <200409271309.17756.dtor_core@ameritech.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <200409270112.29422.dtor_core@ameritech.net> <20040927095348.A29594@unix-os.sc.intel.com>
In-Reply-To: <20040927095348.A29594@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: Len Brown <len.brown@intel.com>, acpi-devel@lists.sourceforge.net, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Monday 27 September 2004 11:53 am, Keshavamurthy Anil S wrote:
> =A0=A0=A0=A0=A0=A0=A0=A0I just wanted to have a single function i.e setup=
_sys_fs_device_files() for both
> creating and removing sysfs files.

Ah, I see... Makes sense, especially when there is additional logic involved
in creating some of the attributes, which is the case with ACPI.

--=20
Dmitry
