From: Don Dugger <n0ano@valinux.com>
Date: Tue, 10 Apr 2001 18:08:36 +0000
Subject: Re: [Linux-ia64] 32 bit compatibility on IA-64
Message-Id: <marc-linux-ia64-105590693005391@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005385@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005385@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Josue-

Good answer, I was just curious.

BTW, I have run IA32 Oracle on my IA64 box and it appears to work
fine.  I got around the Java issue by installing on an IA32 machine
and copying everyting over to the IA64 box.  It at least proved that
the IA32 sub-system supported Oracle and I didn't expect people to
actually run IA32 Oracle on their IA64 machines.

Also, have you looked into Kaffe, `www.kaffe.org'?  It's an open source
JDK that I've compiled for IA64 and used successfully.  I don't know if
it's up to date enough to satisfy your needs though.

On Tue, Apr 10, 2001 at 10:21:10AM -0700, Josue Amaro wrote:
> Don,
> 
> For reasons that I am sure are of very little interest to the people on this list,
> we have dependencies on Java 1.1.8 for some of our products, in particular the
> installer and configuration applets.
> 
> Since there are no plans by anyone to provide Java 1.1.8  for IA-64, we were
> hoping that we could use the 32 bit version of the JRE for installing and
> configuring Oracle on IA-64.
> 
> By the way, I was not really planning on running Oracle, although that may be a
> good test of the functionality of the compatibility environment.
> 
> Regards,
> 
> Don Dugger wrote:
> 
> > Josue-
> >
> > I was hoping nobody would run across this.  The IBM JRE that Oracle
> > is using is using a horrible interface that is disgustingly specific
> > to IA32 that I was hoping I could forget about.  Now that you need
> > it I'll have to implement it for IA64.
> >
> > As a complete aside, can I ask why are you installing the IA32 Oracle
> > on your IA64 machine?  I believe that there is an IA64 version available
> > that might make more sense.
> >
> > On Mon, Apr 09, 2001 at 10:05:46PM -0700, Josue Amaro wrote:
> > > All,
> > >
> > > While testing IA-32 compatibility on IA-64 I ran into this problem:
> > >
> > >  Initializing Java
> > >  Virtual Machine from
> > > ../stage/Components/oracle.swd.jre/1.1.8/1/DataFiles/Expanded/linux/bin/jre.
> > >
> > > Please wait...
> > > ldt_clear: modify_ldt: Function not implemented
> > > ldt_setup: modify_ldt: Function not implemented
> > >
> > > At this point the JRE stops working and exits.
> > >
> > > The Oracle installer runs on IBM's 1.1.8 JRE for Linux (32).
> > >
> > > Regards,
> > > --
> > > "When you see the correct course, act; do not wait for orders."
> > > The Art of War
> > >
> > > ===================================> > >   Josue Emmanuel Amaro                         Josue.Amaro@oracle.com
> > >   Linux Products Manager                       Phone:   650.506.1239
> > >   Intel and Linux Technologies Group           Fax:     650.413.0167
> > > ===================================> > >
> >
> > Content-Description: Card for Josue Amaro
> >
> > --
> > Don Dugger
> > "Censeo Toto nos in Kansa esse decisse." - D. Gale
> > n0ano@valinux.com
> > Ph: 303/938-9838
> 
> --
> "When you see the correct course, act; do not wait for orders."
> The Art of War
> 
> ===================================>   Josue Emmanuel Amaro                         Josue.Amaro@oracle.com
>   Linux Products Manager                       Phone:   650.506.1239
>   Intel and Linux Technologies Group           Fax:     650.413.0167
> ===================================> 

Content-Description: Card for Josue Amaro


-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

