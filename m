From: Piet/Pete Delaney <piet@sgi.com>
Date: Thu, 04 Apr 2002 21:16:50 +0000
Subject: [Linux-ia64] qt-x11-free-3.0.3 - config file seems to be brooken on ia64
Message-Id: <marc-linux-ia64-105590701905383@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I tried to configure the new qt-x11-free-3.0.3 release from:

	ftp://ftp.trolltech.com/qt/source/

on a ia64 running RedHat 7.2 and I'm getting a $EXEC that isn't being 
set up in the confiure file. Anyone know how to fix this? The configure file 
looks the same as the ia32 version as far as $EXEC are concerned.

I'm not sure I understand the logic of the config file, 
it looks like:

	EXEC = PIPE = "$outpath/bin/qmake $QMAKE_SWITCHES $QMAKE_SPEC_ARGS -o $N $a"
-piet

------------------------------------------------------------------------------------
297 piet3 11:21 ~/src/qt/qt-x11-free-3.0.3.ia64> ./configure

This is the Qt/X11 Free Edition.

You are licensed to use this software under the terms of either
the Q Public License (QPL) or the GNU General Public License (GPL).

Type 'Q' to view the Q Public License.
Type 'G' to view the GNU General Public License.
Type 'yes' to accept this license offer.
Type 'no' to decline this license offer.

Do you accept the terms of either license?
tes^?^?^Y

This is the Qt/X11 Free Edition.

You are licensed to use this software under the terms of either
the Q Public License (QPL) or the GNU General Public License (GPL).

Type 'Q' to view the Q Public License.
Type 'G' to view the GNU General Public License.
Type 'yes' to accept this license offer.
Type 'no' to decline this license offer.

Do you accept the terms of either license?
yes
Creating qmake. Please wait...
gmake: *** Warning: File `GNUmakefile' has modification time in the future (2002-04-04 11:56:18 > 2002-04-04 11:55:11)
gmake: Nothing to be done for `all'.
gmake: warning:  Clock skew detected.  Your build may be incomplete.
/home/piet/src/qt/qt-x11-free-3.0.3.ia64/config.tests/unix/stl.test: line 25: 17724 Illegal instruction     (core dumped) $OUTDIR/bin/qmake -nocache -spec "$QMKSPEC" "$ABSPATH" $SRCDIR/config.tests/unix/stltest.pro -o $OUTDIR/config.tests/unix/Makefile >/dev/null 2>&1

        This target is using the GNU C++ compiler (linux-g++).

        Recent versions of this compiler automatically include code for
        exceptions, which increase both the size of the Qt library and the
        amount of memory taken by your applications.

        You may elect to re-run configure with the -no-g++-exceptions
        option to compile Qt without exceptions.  This is completely binary
        compatible, and existing applications should continue to work.


Build type:    linux-g++
Platform notes:

            - Also available for Linux: linux-kcc linux-icc linux-cxx

Configuration .......  nocrosscompiler xftnameunparse minimal-config small-config medium-config large-config full-config release dll png no-gif zlib bigcodecs x11sm xinerama xrender xftfreetype xkb styles tools kernel widgets dialogs iconview workspace network canvas table xml sql
Remote support ...... no
STL support ......... no
Thread support ...... no
GIF support ......... no
MNG support ......... plugin (qt)
JPEG support ........ plugin (qt)
PNG support ......... yes (qt)
OpenGL support ...... no
NAS sound support ... no
Session management .. yes
Xinerama support .... yes
Tablet support ...... no
XRender support ..... yes
XftFreeType support . yes
XKB Support ......... yes

Finding project files. Please wait...
  225 projects found.

Creating makefiles. Please wait...
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/moc/moc.pro
./configure: line 2431: 17841 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/qt.pro
./configure: line 2431: 17848 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/config.tests/unix/stltest.pro
./configure: line 2431: 17855 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/config.tests/x11/notypetest.pro
./configure: line 2431: 17862 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/aclock/aclock.pro
./configure: line 2431: 17869 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/action/actiongroup/actiongroup.pro
./configure: line 2431: 17876 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/action/action.pro
./configure: line 2431: 17883 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/action/toggleaction/toggleaction.pro
./configure: line 2431: 17890 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/examples/addressbook/addressbook.pro

Suspended
---------------------------------------------------------------------------------------------------------------------------
   2370 echo "Creating makefiles. Please wait..."
   2371 # these need to be processed *now*
   2372 for a in `cat .sorted.projects`
   2373 do
   2374     case $a in
   2375     *-kde.pro|*qtmain.pro) continue ;;
   2376     */qmake/qmake.pro) continue ;;
   2377     *-pro.pro)
   2378         if [ "x$Edition" != "xpro" ]
   2379         then
   2380             continue
   2381         fi
   2382         ;;
   2383     *moc*) SPEC=$QMAKESPEC ;;
   2384     *) SPEC=$XQMAKESPEC ;;
   2385     esac
   2386     file=`basename $a`
   2387     dir=`dirname $a | sed -e "s;$sepath;.;g"`
   2388     test -d $dir || mkdir -p $dir
   2389     N=$outpath/$dir/Makefile
   2390     QMAKE_SPEC_ARGS   2391     [ "$SPEC" != "$XQMAKESPEC" ] && QMAKE_SPEC_ARGS="-spec $SPEC"
   2392     PIPE="$outpath/bin/qmake $QMAKE_SWITCHES $QMAKE_SPEC_ARGS -o $N $a"					<-
   2393     if [ "x$OPT_CONCURRENT" = "x0" ] || [ "x$OPT_CONCURRENT" = "x1" ]
   2394     then
   2395         EXEC=$PIPE											<-
   2396     else
   2397         EXEC="$EXEC ($PIPE & ) ;"									<-
   2398         if [ "x$PROCS" != "x$OPT_CONCURRENT" ]
   2399         then
   2400             PROCS=`expr $PROCS + 1`
   2401         else
   2402             PROCS=1
   2403             EXEC="$EXEC wait"
   2404         fi
   2405     fi
   2406
   2407     if echo '\c' | grep '\c' >/dev/null
   2408     then
   2409         echo -n "  for $a"
   2410     else
   2411         echo "  for $a\c"
   2412     fi
   2413     if [ "$OPT_VERBOSE" = "yes" ]
   2414     then
   2415         echo " (`basename $SPEC`)"
   2416         if echo '\c' | grep '\c' >/dev/null
   2417         then
   2418             echo -n "$EXEC"
   2419         else
   2420             echo "$EXEC\c"
   2421         fi
   2422     fi
   2423     echo
   2424
   2425     [ -f "$N" ] && chmod +w $N
   2426     if [ "x$PROCS" = "x1" ]
   2427     then
   2428         /bin/sh -c "$EXEC"									<<---- $EXEC Not Defined
   2429         EXEC=""
   2430     fi
-->2431 done												<<---- HERE
   2432 # this is just in case the concurrent task is not a multiple of the number of tasks
   2433 [ '!' -z "$EXEC" ] && /bin/sh -c "$EXEC wait"
   2434
---------------------------------------------------------------------------------------------------------------------------

When I set the OPT_VERBOSE flag with -v I get:

---------------------------------------------------------------------------------------------------------------------------
Creating makefiles. Please wait...
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/moc/moc.pro (linux-g++)
/home/piet/src/qt/qt-x11-free-3.0.3.ia64/bin/qmake   -o /home/piet/src/qt/qt-x11-free-3.0.3.ia64/./src/moc/Makefile /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/moc/moc.pro
configure: line 2431: 18349 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
  for /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/qt.pro (linux-g++)
/home/piet/src/qt/qt-x11-free-3.0.3.ia64/bin/qmake   -o /home/piet/src/qt/qt-x11-free-3.0.3.ia64/./src/Makefile /home/piet/src/qt/qt-x11-free-3.0.3.ia64/src/qt.pro
configure: line 2431: 18359 Illegal instruction     (core dumped) /bin/sh -c "$EXEC"
---------------------------------------------------------------------------------------------------------------------------

