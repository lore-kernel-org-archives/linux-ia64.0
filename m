From: Robin Holt <holt@sgi.com>
Date: Sat, 11 Feb 2006 12:21:25 +0000
Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <20060211122125.GC889@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05AD5E4F@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05AD5E4F@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Moore, Robert" <robert.moore@intel.com>, Thomas Renninger <trenn@suse.de>, "Brown, Len" <len.brown@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

Tony,

Did you compile with CONFIG_DEBUG_INFO?  If so, an
objdump -l --start-address=3D0xa0000001003afaa0 --stop-address=A0000001003b=
0000 vmlinux
would give us an idea of the line number and operation being performed.

Thanks,
Robin


On Fri, Feb 10, 2006 at 04:39:55PM -0800, Luck, Tony wrote:
> kernel unaligned access to 0xe000004040e7263c, ip=3D0xa0000001003afb00
> Badness in ia64_handle_unaligned at arch/ia64/kernel/unaligned.c:1349
