From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 12 Feb 2001 22:04:10 +0000
Subject: Re: [Linux-ia64] modutils 2.4.2 and USB
Message-Id: <marc-linux-ia64-105590693005141@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 12 Feb 2001 09:14:27 -0800, 
Michael Madore <mmadore@turbolinux.com> wrote:
>depmod: Module /lib/modules/2.4.1-010131-1smp/kernel/drivers/usb/acm.o has
>an unknown version (2) usb_device table
>	It is likely that the kernel structure has changed, if so then
>	you probably need a new version of modutils to handle this kernel.
>	Check linux/Documentation/Changes.

Somebody has included patch-2.4.0-hotplug.gz in your source tree.  That
patch is not to be used.


