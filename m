From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 30 Jun 2004 23:18:55 +0000
Subject: Re: Linker bug in Debian unstable?
Message-Id: <20040630231855.GA30119@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040630192143.GE30334@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040630192143.GE30334@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 30, 2004 at 11:40:40PM +0100, Matthew Wilcox wrote:
> On Wed, Jun 30, 2004 at 01:15:30PM -0700, H. J. Lu wrote:
> > That is the one I checked into CVS. I don't know if it will work for
> > the binutils.
> 
> Thanks for that.  Unfortunately, it seems to not be enough; when I apply it
> to Debian's binutils (and fix up some rejects, no big deal), I get:
> 
>  cc -shared  .libs/libgnometypebuiltins.o .libs/gnome-config.o .libs/gnome-sound
> .o .libs/gnome-triggers.o .libs/gnome-program.o .libs/gnome-help.o .libs/gnome-e
> xec.o .libs/gnome-gconf.o .libs/gnome-i18n.o .libs/gnome-url.o .libs/gnome-util.
> o .libs/gnome-score.o .libs/gnome-init.o  -L/usr/lib -pthread /usr/lib/libgnomev
> fs-2.so /usr/lib/libbonobo-2.so /usr/lib/libbonobo-activation.so /usr/lib/libgco
> nf-2.so /usr/lib/libORBit-2.so /usr/lib/libgmodule-2.0.so -ldl /usr/lib/libgthre
> ad-2.0.so /usr/lib/libglib-2.0.so /usr/lib/libesd.so /usr/lib/libaudiofile.so -l
> m /usr/lib/libpopt.so  -Wl,-z -Wl,defs -Wl,-O1 -Wl,--export-dynamic -Wl,-soname 
> -Wl,libgnome-2.so.0 -Wl,-version-script -Wl,.libs/libgnome-2.ver -o .libs/libgno
> me-2.so.0.601.0
> .libs/libgnometypebuiltins.o(.text+0x52): In function `gnome_trigger_type_get_ty
> pe':
> /home/willy/debian/gnmoe/libgnome-2.6.1/libgnome/libgnometypebuiltins.c:24: unde
> fined reference to `g_enum_register_static'
> (millions more undefined references follow)
> 

That is what this patch is supposed to do. When you pass "-z defs" to
the linker, you'd better to make sure there are no undefined references.
The old linker just generated bad binaries with "-z defs".



H.J.
