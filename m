From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 May 2003 16:34:31 +0000
Subject: RE: [Linux-ia64] keyboard problems with post 2.4.17 kernels on proliant dl590 (itanium)
Message-Id: <marc-linux-ia64-105590723705797@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705796@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705796@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I've been having difficulty compiling a kernel that provides a working
> keyboard from sources newer than 2.4.17 - is this a known problem
> (google sheds no light on things)? I can't see anything in dmesg to
> suggest an error but as soon as elilo hands loads the kernel, I lose
> the ability to input anything through the keyboard.
> 
> This is with vanilla kernel sources (2.4.18, 2.4.19 and 2.4.20) +
> official ia64 patches and with debian kernel sources.

USB or PS/2 keyboard?

On PS/2 ... I've had problems on various versions of Linux on my
BigSur where the keyboard doesn't work.  Unplugging and re-plugging
the keyboard (and then typing a few characters) always seems to
unjam it.

On USB ... I often fail to get all the config options right to enable
the keyboard ... but that's a personal problem.

-Tony

