From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Tue, 13 Jun 2000 19:53:59 +0000
Subject: Re: [Linux-ia64] USB Support
Message-Id: <marc-linux-ia64-105590678205138@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205134@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205134@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 13, 2000, Jonathan_Kwahk@Dell.com <Jonathan_Kwahk@Dell.com> wrote:
> BIOS builds 47 and 50 (with PAL50) does support SOME USB keyboards.  I have
> had problems with the Microsoft (real nice one with Explorer keys) keyboard,
> but the MS Elite USB keyboard works in the EFI shell.
> 
> I believe it's somewhat hardware/BIOS for the incompatibility.

Could be. The BIOS is most likely using the HID boot protocol which is
minimal enough that fixing any problems shouldn't be too difficult.

> TurboLinux 0505 build does NOT support USB keyboards with the installer.

Ahh. My 0406 and 0505 build systems have USB support with one of the
keyboard drivers. I thought they used the same kernel to install as
they did after the install.

> RedHat's latest build hasn't been tested by me, yet.

Nor here.

JE



