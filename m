From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Mon, 12 Feb 2001 19:53:41 +0000
Subject: Re: [Linux-ia64] modutils 2.4.2 and USB
Message-Id: <marc-linux-ia64-105590693005140@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 12, 2001, Michael Madore <mmadore@turbolinux.com> wrote:
> On Mon, Feb 12, 2001 at 11:41:13AM -0800, Johannes Erdfelt wrote:
> > That is definately weird. Keith Owens wanted to add a version information
> > to help fix a problem we ran into with 2.4.0.
> > 
> > Right before 2.4.0 we had to modify the usb_device_id structure to add some
> > extra information to make it work correctly. However, this didn't change
> > the size of the structure (because of alignment reasons) and as a result
> > it was difficult for modutils to tell the difference between the old style
> > structure and the new style structure.
> > 
> > Both Linus and I didn't want to add the version information in 2.4 and we
> > just told him to drop the support for the old style structure since it was
> > only found in development kernels.
> > 
> > The code stayed in modutils it appears since it wouldn't get in the way
> > of anything and it would be used in 2.5.
> > 
> > But, the patch never went into the kernel and it shouldn't be finding any
> > version information. Is there a __module_usb_device_ver symbol in acm.o?
> 
> Yes, acm.o has a symbol called __module_usb_device_ver.  If I temporarily
> remove acm.o, I get the same message for audio.o, so it isn't a problem just
> with that module.

Exactly which patches did you apply? My ia64 development system only has
the symbols which should be there.

0000000000000020 ? __module_author
0000000000000068 ? __module_description
0000000000000000 ? __module_kernel_version
0000000000000000 g __module_usb_device_size
0000000000000008 g __module_usb_device_table
                 U __this_module

JE


