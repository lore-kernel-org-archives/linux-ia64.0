From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sat, 04 May 2019 05:47:08 +0000
Subject: Re: ERROR: "paddr_to_nid" [drivers/md/raid1.ko] undefined!
Message-Id: <0f33a863-4371-06cb-f4bd-1f95165b18f1@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <201905032019.tzlqufi0%lkp@intel.com>
 <4e48dcb2-6e82-4bbe-3920-e1c5fd5c265a@infradead.org>
 <3908561D78D1C84285E8C5FCA982C28F7E91BABF@ORSMSX104.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7E91BABF@ORSMSX104.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>, Ming Lei <ming.lei@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, lkp <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Omar Sandoval <osandov@fb.com>, Christoph Hellwig <hch@lst.de>, "Wu, Fengguang" <fengguang.wu@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Hi Tony!

On 5/3/19 10:25 PM, Luck, Tony wrote:
> Big difference is I'm doing a natinve build with a much older compiler (4=
.6.4)

Just as a heads-up: There are updated installation images available
for Debian unstable for ia64 [1]. Those install a fresh system using GRUB
as a bootloader and come with the latest versions of the toolchain.

Please keep in mind that the kernel is currently unbootable on some machines
due to a miscompiled kernel due to a bug in gcc-8 [2]. However, there is al=
ready
a fix for this particular gcc bug and it has also been backported to gcc-8 =
as
of yesterday, so we're just waiting for Debian's gcc-8 package to be updated
so we can rebuild the kernel packages and the installation image.

The network mirror and remote directory which are being prompted for during
installation are:

- Mirror: http://ftp.ports.debian.org
- Directory: debian-ports

Thanks,
Adrian

> [1] https://cdimage.debian.org/cdimage/ports/grub-test/
> [2] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=86984

--=20
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
