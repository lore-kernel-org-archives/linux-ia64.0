From: "Doran, Mark" <mark.doran@intel.com>
Date: Fri, 05 Jan 2001 20:08:58 +0000
Subject: RE: [Linux-ia64] fdisk for efi disks?
Message-Id: <marc-linux-ia64-105590678205889@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205863@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205863@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

within the next week or two we expect to be able to release three EFI
utilities that help to manage GPT partitions:

- diskpart.efi (semantic equivalent to FDISK, but for GPT)
- efifmt.efi (semantic equivalent to FORMAT, for EFI FAT)
- efichk.efi (semantic equivalent to SCANDISK, for EFI FAT)

These will come in binary and source form.  For use as EFI utilities (say
from the EFI shell prompt or started from the boot manager), we would
recommend using the binaries as-is for maximum compatibility of course.  The
source will be provided so that if you want to make versions that run in
OS-present environments, you can do that as well.

The utilities have been through beta test and are just now coming back to me
again for packaging prior to release so it shouldn't be long now.  These
will be available for download from the EFI web pages on Intel's Developer
site ( http://developer.intel.com/technology/efi ) with a click-wrap license
similar to the one in use for the sample code and the toolkit that are
already on the site.

While I can't say for sure one way or the other, I have heard no plans from
Microsoft to make versions of their DOS disk management tools that support
GPT.  You would need to approach Microsoft directly for the definitive
answer on that though.

Thanks to Sunil Saxena for passing this along (I'm not on the mailias for
this group so if you want me to see replies, please make sure to copy me
explicitly).

Hope that helps!

Cheers,

Mark.
--
Mark Doran
EFI Program Manager
Intel Corp.

> -----Original Message-----
> From: Matt_Domsch@Dell.com [mailto:Matt_Domsch@Dell.com]
> Sent: Friday, January 05, 2001 11:22 AM
> To: josef.moellers@fujitsu-siemens.com; linux-ia64@linuxia64.org
> Subject: RE: [Linux-ia64] fdisk for efi disks?
> 
> 
> > I'm a new kid on the block and I was interested if anyone 
> was already
> > working on an fdisk replacement/enhancement to be used on efi disks?
> 
> I started work to add GPT support to GNU parted, but made it 
> for 1.2.x, not
> the current 1.4.x, and haven't had the time to do the 
> forward-port.  If
> you've got the time, I'm happy to send you my original patch.
> 
> > I wonder if enhancing fdisk such that it also handles efi 
> > disks would be
> > better than building a new tool (efdisk)?
> 
> Modifying fdisk would be useful too, IMHO.
> 
> Thanks,
> Matt Domsch
> Dell Enterprise Systems Group
> Linux Development Team
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


