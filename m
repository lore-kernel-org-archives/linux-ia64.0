From: Chris Ahna <christopher.j.ahna@intel.com>
Date: Tue, 14 Aug 2001 05:58:31 +0000
Subject: Re: [Linux-ia64] AGP
Message-Id: <marc-linux-ia64-105590698805070@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693006009@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693006009@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Martin Wilck wrote:
> The following patch gets rid of the agpgart.o undefined symbol errors.
> However, loading the module fails on Lion with -ENODEV (no surprise, since
> there's no AGP slot). That means that the DRM modules for ATI cards
> also cannot be loaded => no DRI on Lion except with Matrox (I think the
> Matrox DRM driver does not require AGP to be loaded).

The patch is absolutely correct, thanks.  I haven't used any ia64 kernel
past 2.4.4 so this one slipped by me.

Martin Wilck wrote (a little earlier):
> I am wondering to which extent AGP and DRI are supported by Linux-IA64.
> So far I have always configured agpgart and DRI into my kernels, but I
> keep getting depmod error messages:
...
> On Lion at least, there is no AGP bus anyway. I don't know about Big
> Sur, but the option "Enable full AGP RQ (requires Big Sur BIOS 99 or newer)
> seems to suggest that Big Sur supports AGP.
> 
> My questions:
> - Is it correct that AGP/DRI support makes no sense on Lion?
> - What about BigSur?

AGP support doesn't exist on Lion, however DRI doesn't strictly require
AGP.  I've been meaning to look into running PCI DRI on Lion for some
time.  BigSur has an AGP port on the baseboard and supports AGP fully.

As far as the general state of AGP/DRI on ia64 goes, the situation is a
little complicated.

All the code needed to support AGP and DRI on ia64 has been generated,
however the right patches haven't ended up in all the right places just
yet.  The working combination that most people have used is:

i)  agpgart and drm modules from the 2.4.[234] ia64 kernel tree
ii) a patched version of XFree86 4.0.[23]

With XFree86 4.1.0, drm was pretty heavily redesigned, making the drm
modules from the ia64 kernel incompatible with newer Xservers.  The new
drm was finally integrated into the mainline kernel (it had been
maintained as a kernel module existing in the XFree86 source tree) with
the release of 2.4.8.

The best thing to do would be to add ia64 AGP/DRI support to both the
mainline kernel and the XFree86/DRI CVS repositories.  I'm discussing
this with the appropriate maintainers this week.  If this can be done,
then AGP/DRI will finally work out of the box on ia64 after stock kernel
and XFree86 builds.  Otherwise I suppose I'll post updated patches to
this list to support both

i)  old drm + XFree86 4.0.[23]
ii) new drm + XFree86 4.1.x

Sorry this has slid so badly over the past few months, I should have
more information in a few days.

Chris

