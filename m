From: "H . J . Lu" <hjl@valinux.com>
Date: Mon, 05 Feb 2001 19:57:31 +0000
Subject: Re: [Linux-ia64] The 1117 snapshot cpp problem
Message-Id: <marc-linux-ia64-105590693005114@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205880@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205880@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 24, 2001 at 01:37:24PM -0800, Jim Wilson wrote:
> >I guess it is a long standing issue in the Cygnus toolchain. The
> >problem is this change:
> >Bascallly, it sets local_prefix = prefix, which means
> >$local_prefix/include = $prefix/include
> 
> >Now, gcc will search /usr/include before others. It is not very good
> >for Linux.
> 
> Yes, this is a problem.
> 
> I've reverted the Cygnus local change in my source tree, and have started
> working to get the same change into the main Cygnus source tree.  This will
> require changing some local build processes, so it may take a little time.
> 
> There is no problem with cross compilers as you suggested, because cross
> compilers don't use /usr/local/include.  I believe the original problem was
> that we shipped compilers to some customers that had random files in
> /usr/local, the customers reported problems, and we had a lot of trouble
> debugging the problem.  We fixed it by deciding not to use /usr/local/include
> by default anymore.  This was 8 years ago, so Linux usage was not a concern.
> Now that we are part of Red Hat, it is a serious concern.
> 
> The resulting patch is 100K because configure had to be rebuilt.  I put it
> in the usual place, ftp.cygnus.com:/pub/ia64-linux/snap-001117/patch.055.
> 

I don't think it works with the gnupro rpm from RedHat. I had to
add the patch enclosed here. I think the problem is includedir in gcc
is overriden from the toplevel Makefile.

-- 
H.J. Lu (hjl@valinux.com)
---
--- gcc/Makefile.in.local	Thu Jan  4 15:21:25 2001
+++ gcc/Makefile.in	Thu Jan  4 15:22:00 2001
@@ -292,7 +292,7 @@ build_tooldir = $(exec_prefix)/$(target_
 # Directory in which the compiler finds g++ includes.
 gcc_gxx_include_dir= @gcc_gxx_include_dir@
 # Directory to search for site-specific includes.
-includedir = $(local_prefix)/include
+localincludedir = $(local_prefix)/include
 # assertdir is overridden in cross-make.
 # (But this currently agrees with what is in cross-make.)
 assertdir = $(gcc_tooldir)/include
@@ -1881,7 +1881,7 @@ intl.distdir-fixup:
 PREPROCESSOR_DEFINES = \
   -DGCC_INCLUDE_DIR=\"$(libsubdir)/include\" \
   -DGPLUSPLUS_INCLUDE_DIR=\"$(gcc_gxx_include_dir)\" \
-  -DLOCAL_INCLUDE_DIR=\"$(includedir)\" \
+  -DLOCAL_INCLUDE_DIR=\"$(localincludedir)\" \
   -DCROSS_INCLUDE_DIR=\"$(gcc_tooldir)/sys-include\" \
   -DTOOL_INCLUDE_DIR=\"$(gcc_tooldir)/include\"
 
@@ -2447,7 +2447,7 @@ installdirs:
 	  if [ -d $${fdir} ] ; then true ; else mkdir $${fdir}; chmod a+rx $${fdir}; fi ; \
 	done
 	-if [ -d $(bindir) ] ; then true ; else mkdir $(bindir) ; chmod a+rx $(bindir) ; fi
-	-if [ -d $(includedir) ] ; then true ; else mkdir $(includedir) ; chmod a+rx $(includedir) ; fi
+	-if [ -d $(localincludedir) ] ; then true ; else mkdir $(localincludedir) ; chmod a+rx $(localincludedir) ; fi
 	-if [ -d $(gcc_tooldir) ] ; then true ; else mkdir $(gcc_tooldir) ; chmod a+rx $(gcc_tooldir) ; fi
 	-if [ -d $(assertdir) ] ; then true ; else mkdir $(assertdir) ; chmod a+rx $(assertdir) ; fi
 	-if [ -d $(infodir) ] ; then true ; else mkdir $(infodir) ; chmod a+rx $(infodir) ; fi

