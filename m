From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 13 Jan 2017 16:01:01 +0000
Subject: Re: [PATCH v3 1/8] arm: put types.h in uapi
Message-Id: <4633e475-47f2-5627-81a9-a1747dfddbc0@6wind.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1484304406-10820-2-git-send-email-nicolas.dichtel@6wind.com>
 <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
 <25063.1484321803@warthog.procyon.org.uk>
In-Reply-To: <25063.1484321803@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: David Howells <dhowells@redhat.com>
Cc: arnd@arndb.de, linux-mips@linux-mips.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, alsa-devel@alsa-project.org, dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-am33-list@redhat.com, linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, linux@armlinux.org.uk, coreteam@netfilter.org, fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org, linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, linux-kbuild@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org

Please, do not remove the email subject when you reply. I restore it to eas=
e the
thread follow-up.

Le 13/01/2017 =E0 16:36, David Howells a =E9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>=20
>> This header file is exported, thus move it to uapi.
>=20
> Exported how?
It is listed in include/uapi/asm-generic/Kbuild.asm, which is included by
arch/arm/include/uapi/asm/Kbuild.

You can also have a look at patch #5 to see why it was exported even if it =
was
not in an uapi directory.

Regards,
Nicolas
