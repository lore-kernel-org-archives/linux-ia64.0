From: Don Dugger <n0ano@valinux.com>
Date: Sat, 26 Aug 2000 03:19:28 +0000
Subject: Re: [Linux-ia64] Re: [Ia64] Netscape (32-bit) locks machine
Message-Id: <marc-linux-ia64-105590678205390@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205388@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205388@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike-

I must have been asleep since I don't remember seeing the original message.

If your machine is crashing when running Netscape I would be suspicious of
Netscape before I'd blame the X server.  I just discovered a few weeks
ago that you have to put the system in `trickle' mode if you want to run
IA32 programs, including Netscape, reliably.  I understand you can set
`trickle' mode on the Lion BIOS.  For BigSur's there's a patch for the
kernel you can get from Intel to do this (I can't send you the patch, you
need to send a message to `Asit.K.Mallick@intel.com' if you want it).

I hope this helps.

On Fri, Aug 25, 2000 at 05:35:42PM -0700, Michael Madore wrote:
> On Thu, 24 Aug 2000, Marc Aurele La France wrote:
> 
> > On Thu, 24 Aug 2000, Michael Madore wrote:
> > 
> > > > > > I am running into an issue where Netscape will often lock up the entire
> > > > > > machine when launched.  It isn't just the X Server crashing, the
> > > > > > entire system is frozen.  This happens on both Rage 128 and Rage XL.  On
> > > > > > the Rage XL, I virtually eliminated the lock ups by removing latin2 fonts
> > > > > > from my XF86Config file.  With the Rage 128, nothing seems to help,
> > > > > > including using option "noaccel" for the driver.  We are using XFree 4.0.1
> > > > > > with patches (essentially the same patches that were just posted.)
> > 
> > > > >    Could be a bug in one of the font renderers.  I know the FreeType
> > > > > renderer has some bugs.  
> > 
> > > > Ummm.  Looks like there are similar problems with the latest builds on
> > > > ia32.
> > 
> > > After doing some further testing, I have found that X seems to lock the
> > > machine hard on our Lion boxes pretty much all the time.  Just starting X
> > > will sometimes lock them up.  These boxes are all using the r128 driver.
> > 
> > > I am going to try the latest code from CVS tomorrow and see if there is
> > > any improvment.  If not, what can I do to help track down where the
> > > problem is coming from?
> > 
> > Well, on the assumption that it is a font renderer problem, you can try
> > whittling down your font path until the problem stops happening.  Start by
> > removing TrueType (or clone), then Type1, Speedo, etc.  If your running
> > xfs, get rid of it first.
> 
> I went ahead and cut down my fonts to pretty much nothing.  The problem
> still occurs.  I turned off acceleration on the Lion boxes, and that
> allows our install program to run without X crashing.  With acceleration
> turned on, the machine will hang if you use a scroll bar to move through a
> large text list.
> 
> It was pointed out to me that /dev/mem needs to be opened with O_SYNC, so
> that it will not be mapped write-cache.  Mapping it with write cache can
> cause lockups.  I have a patch applied in os-support/lnx_video.c that
> fixes this problem, but I still get lockups.  I was wondering if there
> are any other places in the code where this could be happening?
> 
> Mike Madore
> Software Engineer
> TurboLinux, Inc.
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

