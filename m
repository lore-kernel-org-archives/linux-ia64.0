From: Piet/Pete Delaney <piet@sgi.com>
Date: Fri, 05 Apr 2002 02:37:02 +0000
Subject: Re: [lkcd-devel] Re: [Linux-ia64] qt-x11-free-3.0.3 - config file seems to be brooken on ia64; Looks
Message-Id: <marc-linux-ia64-105590701905388@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, Apr 04, 2002 at 06:10:24PM -0800, Piet/Pete Delaney wrote:

Looks like g++ version 3.0.2 IS brooken on ia64; at least as I ended up bui=
lding it on RedHat 7.2.

After compiling qt-x11-free-3.0.3 qmake with the new 3.0.2 g++ hidden=20
form the search path qmake doesn't SEGV.

NB:=20
	qt-x11-free-3.0.3 is available from ftp://ftp.trolltech.com/qt/source/.

gcc 3.0.2 seems to be fine; compiles linux kernels fine.

-piet


> On Thu, Apr 04, 2002 at 01:16:50PM -0800, Piet/Pete Delaney wrote:
>=20
> Looks like qmake is trying to delete with a NULL pointer yet
> the code seems to test for this condition:
>=20
> #0  operator delete[](void*) (ptr=3D0x0) at del_opv.cc:35
> #1  0x40000000002517f0 in ~QStringData (__in_chrg=95456) at /home/piet/sr=
c/qt/qt-x11-free-3.0.3.ia64/src/tools/qstring.h:349
> #2  0x4000000000195d80 in QString::deref() (this=3D0x80000fffffffa920) at=
 /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/tools/qstring.cpp:12710
> #3  0x4000000000195ec0 in QString::operator=3D(QString const&) (this=3D0x=
80000fffffffa920, s=3D@0x80000fffffffa8c0) at /home/piet/src/qt/qt-x11-free=
-3.0.3.ia64/src/tools/qstring.cpp:12741
> #4  0x4000000000132e40 in default_mode (progname=CAnnot access memory at =
address 0x0
> ) at option.cpp:151
> #5  0x40000000001346a0 in Option::parseCommandLine(int, char**) (argc=3D1=
, argv=3D0x80000fffffffb518) at option.cpp:268
> #6  0x40000000000181b0 in main (argc=3D1, argv=3D0x80000fffffffb518) at m=
ain.cpp:71
> (gdb) up
> #1  0x40000000002517f0 in ~QStringData (__in_chrg=95456) at /home/piet/sr=
c/qt/qt-x11-free-3.0.3.ia64/src/tools/qstring.h:349
> (gdb)=20
>=20
>=20
> (gdb) print *d
> $13 =3D {
>   <QShared> =3D {
>     count =3D 0
>   },=20
>   members of QStringData:=20
>   unicode =3D 0x6000000000017460,=20
>   ascii =3D 0x0,=20
>   len =3D 54,=20
>   simpletext =3D 1,=20
>   maxl =3D 54,=20
>   dirty =3D 1
> }
> (gdb)=20
>=20
> I wonder if gcc version 3.0.2 is brooken on ia64 for c++ code. Compilers =
are very seldom brooken and
> 3.0.2 is working fine on the kernel.
>=20
> Any thoughts/suggestions?
>=20
> -piet
>=20
>=20
>=20
> > I tried to configure the new qt-x11-free-3.0.3 release from:
> >=20
> > 	ftp://ftp.trolltech.com/qt/source/
> >=20
> > on a ia64 running RedHat 7.2 and I'm getting a $EXEC that isn't being=20
> > set up in the confiure file. Anyone know how to fix this? The configure=
 file=20
> > looks the same as the ia32 version as far as $EXEC are concerned.
> >=20
> > I'm not sure I understand the logic of the config file,=20
> > it looks like:
> >=20
> > 	EXEC =3D PIPE =3D "$outpath/bin/qmake $QMAKE_SWITCHES $QMAKE_SPEC_ARGS=
 -o $N $a"
> > -piet
> >=20
> > -----------------------------------------------------------------------=
-------------
> > 297 piet3 11:21 ~/src/qt/qt-x11-free-3.0.3.ia64> ./configure
> >=20
> > This is the Qt/X11 Free Edition.
> >=20
> > You are licensed to use this software under the terms of either
> > the Q Public License (QPL) or the GNU General Public License (GPL).
> >=20
> > Type 'Q' to view the Q Public License.
> > Type 'G' to view the GNU General Public License.
> > Type 'yes' to accept this license offer.
> > Type 'no' to decline this license offer.
> >=20
> > Do you accept the terms of either license?
> > tes^?^?^Y
> >=20
> > This is the Qt/X11 Free Edition.
> >=20
> > You are licensed to use this software under the terms of either
> > the Q Public License (QPL) or the GNU General Public License (GPL).
> >=20
> > Type 'Q' to view the Q Public License.
> > Type 'G' to view the GNU General Public License.
> > Type 'yes' to accept this license offer.
> > Type 'no' to decline this license offer.
> >=20
> > Do you accept the terms of either license?
> > yes
> > Creating qmake. Please wait...
> > gmake: *** Warning: File `GNUmakefile' has modification time in the fut=
ure (2002-04-04 11:56:18 > 2002-04-04 11:55:11)
> > gmake: Nothing to be done for `all'.
> > gmake: warning:  Clock skew detected.  Your build may be incomplete.
> > /home/piet/src/qt/qt-x11-free-3.0.3.ia64/config.tests/unix/stl.test: li=
ne 25: 17724 Illegal instruction     (core dumped) $OUTDIR/bin/qmake -nocac=
he -spec "$QMKSPEC" "$ABSPATH" $SRCDIR/config.tests/unix/stltest.pro -o $OU=
TDIR/config.tests/unix/Makefile >/dev/null 2>&1
> >=20
> >         This target is using the GNU C++ compiler (linux-g++).
> >=20
> >         Recent versions of this compiler automatically include code for
> >         exceptions, which increase both the size of the Qt library and =
the
> >         amount of memory taken by your applications.
> >=20
> >         You may elect to re-run configure with the -no-g++-exceptions
> >         option to compile Qt without exceptions.  This is completely bi=
nary
> >         compatible, and existing applications should continue to work.
> >=20
> >=20
> > Build type:    linux-g++
> > Platform notes:
> >=20
> >             - Also available for Linux: linux-kcc linux-icc linux-cxx
> >=20
> > Configuration .......  nocrosscompiler xftnameunparse minimal-config sm=
all-config medium-config large-config full-config release dll png no-gif zl=
ib bigcodecs x11sm xinerama xrender xftfreetype xkb styles tools kernel wid=
gets dialogs iconview workspace network canvas table xml sql
> > Remote support ...... no
> > STL support ......... no
> > Thread support ...... no
> > GIF support ......... no
> > MNG support ......... plugin (qt)
> > JPEG support ........ plugin (qt)
> > PNG support ......... yes (qt)
> > OpenGL support ...... no
> > NAS sound support ... no
> > Session management .. yes
> > Xinerama support .... yes
> > Tablet support ...... no
> > XRender support ..... yes
> > XftFreeType support . yes
> > XKB Support ......... yes
> >=20
> > Finding project files. Please wait...
> >   225 projects found.
> >=20
> > Creating makefiles. Please wait...
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/moc/moc.pro
> > ./configure: line 2431: 17841 Illegal instruction     (core dumped) /bi=
n/sh -c "$EXEC"
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/qt.pro
> > ./configure: line 2431: 17848 Illegal instruction     (core dumped) /bi=
n/sh -c "$EXEC"
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/config.tests/unix/stltes=
t.pro
> > ./configure: line 2431: 17855 Illegal instruction     (core dumped) /bi=
n/sh -c "$EXEC"
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/config.tests/x11/notypet=
est.pro
> > ./configure: line 2431: 17862 Illegal instruction     (core dumped) /bi=
n/sh -c "$EXEC"
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/aclock/aclock.p=
ro
> > ./configure: line 2431: 17869 Illegal instruction     (core dumped) /bi=
n/sh -c "$EXEC"
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/action/actiongr=
oup/actiongroup.pro
> > ./configure: line 2431: 17876 Illegal instruction     (core dumped) /bi=
n/sh -c "$EXEC"
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/action/action.p=
ro
> > ./configure: line 2431: 17883 Illegal instruction     (core dumped) /bi=
n/sh -c "$EXEC"
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/action/toggleac=
tion/toggleaction.pro
> > ./configure: line 2431: 17890 Illegal instruction     (core dumped) /bi=
n/sh -c "$EXEC"
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/addressbook/add=
ressbook.pro
> >=20
> > Suspended
> > -----------------------------------------------------------------------=
----------------------------------------------------
> >    2370 echo "Creating makefiles. Please wait..."
> >    2371 # these need to be processed *now*
> >    2372 for a in `cat .sorted.projects`
> >    2373 do
> >    2374     case $a in
> >    2375     *-kde.pro|*qtmain.pro) continue ;;
> >    2376     */qmake/qmake.pro) continue ;;
> >    2377     *-pro.pro)
> >    2378         if [ "x$Edition" !=3D "xpro" ]
> >    2379         then
> >    2380             continue
> >    2381         fi
> >    2382         ;;
> >    2383     *moc*) SPEC=3D$QMAKESPEC ;;
> >    2384     *) SPEC=3D$XQMAKESPEC ;;
> >    2385     esac
> >    2386     file=3D`basename $a`
> >    2387     dir=3D`dirname $a | sed -e "s;$sepath;.;g"`
> >    2388     test -d $dir || mkdir -p $dir
> >    2389     N=3D$outpath/$dir/Makefile
> >    2390     QMAKE_SPEC_ARGS> >    2391     [ "$SPEC" !=3D "$XQMAKESPEC"=
 ] && QMAKE_SPEC_ARGS=3D"-spec $SPEC"
> >    2392     PIPE=3D"$outpath/bin/qmake $QMAKE_SWITCHES $QMAKE_SPEC_ARGS=
 -o $N $a"					<-
> >    2393     if [ "x$OPT_CONCURRENT" =3D "x0" ] || [ "x$OPT_CONCURRENT" =
=3D "x1" ]
> >    2394     then
> >    2395         EXEC=3D$PIPE											<-
> >    2396     else
> >    2397         EXEC=3D"$EXEC ($PIPE & ) ;"									<-
> >    2398         if [ "x$PROCS" !=3D "x$OPT_CONCURRENT" ]
> >    2399         then
> >    2400             PROCS=3D`expr $PROCS + 1`
> >    2401         else
> >    2402             PROCS=3D1
> >    2403             EXEC=3D"$EXEC wait"
> >    2404         fi
> >    2405     fi
> >    2406
> >    2407     if echo '\c' | grep '\c' >/dev/null
> >    2408     then
> >    2409         echo -n "  for $a"
> >    2410     else
> >    2411         echo "  for $a\c"
> >    2412     fi
> >    2413     if [ "$OPT_VERBOSE" =3D "yes" ]
> >    2414     then
> >    2415         echo " (`basename $SPEC`)"
> >    2416         if echo '\c' | grep '\c' >/dev/null
> >    2417         then
> >    2418             echo -n "$EXEC"
> >    2419         else
> >    2420             echo "$EXEC\c"
> >    2421         fi
> >    2422     fi
> >    2423     echo
> >    2424
> >    2425     [ -f "$N" ] && chmod +w $N
> >    2426     if [ "x$PROCS" =3D "x1" ]
> >    2427     then
> >    2428         /bin/sh -c "$EXEC"									<<---- $EXEC Not Defined
> >    2429         EXEC=3D""
> >    2430     fi
> > -->2431 done												<<---- HERE
> >    2432 # this is just in case the concurrent task is not a multiple of=
 the number of tasks
> >    2433 [ '!' -z "$EXEC" ] && /bin/sh -c "$EXEC wait"
> >    2434
> > -----------------------------------------------------------------------=
----------------------------------------------------
> >=20
> > When I set the OPT_VERBOSE flag with -v I get:
> >=20
> > -----------------------------------------------------------------------=
----------------------------------------------------
> > Creating makefiles. Please wait...
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/moc/moc.pro (linux-g=
++)
> > /home/piet/src/qt/qt-x11-free-3.0.3.ia64/bin/qmake   -o /home/piet/src/=
qt/qt-x11-free-3.0.3.ia64/./src/moc/Makefile /home/piet/src/qt/qt-x11-free-=
3.0.3.ia64/src/moc/moc.pro
> > configure: line 2431: 18349 Illegal instruction     (core dumped) /bin/=
sh -c "$EXEC"
> >   for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/qt.pro (linux-g++)
> > /home/piet/src/qt/qt-x11-free-3.0.3.ia64/bin/qmake   -o /home/piet/src/=
qt/qt-x11-free-3.0.3.ia64/./src/Makefile /home/piet/src/qt/qt-x11-free-3.0.=
3.ia64/src/qt.pro
> > configure: line 2431: 18359 Illegal instruction     (core dumped) /bin/=
sh -c "$EXEC"
> > -----------------------------------------------------------------------=
----------------------------------------------------
> >=20
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
>=20
> _______________________________________________
> lkcd-devel mailing list
> lkcd-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lkcd-devel

