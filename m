From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Wed, 14 Nov 2001 18:38:14 +0000
Subject: [Linux-ia64] Gcj static Java compiler on Itanium
Message-Id: <marc-linux-ia64-105590698805515@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Gcj is the gcc Java front end and associated runtime.  It is primarily a
static Java to native code compiler, though it can also dynamically load and
interpret .class files.  See http://gcc.gnu.org/java for details.  

I now have a reasonably functional version of gcj running on Itanium.  Since
it will take a while to clean up patches and to merge them back into the
official gcc tree, I temporarily put three files in
ftp://ftp.hpl.hp.com/pub/linux-ia64/ :

md5sum:				    filename:
4c7058c8499fa0757f3e882bf1a1e404  gcc-pre3.1-2001-10-24.patch
3187808e9b79fd97bb983f76c190ec75  gcc-pre3.1-2001-10-24.src.tgz
cf40f4941cf0780ca41184584a66fff3  gcc-pre3.1-2001-10-24.tgz

gcc-pre3.1-2001-10-24.patch: A set of patches, mostly in need of cleanup,
which aren't yet in the official tree. 

gcc-pre3.1-2001-10-24.src.tgz: The gcc snapshot I've been using (~ Oct. 24)
with the patches applied.  (This is otherwise hard to reproduce, since it
doesn't quite correspond to a single point in time.  It includes a few more
recent fixes.)

gcc-pre3.1-2001-10-24.tgz: A tar file containing gcc and binutils
executables, the former built form the preceding snaphot after configuring
with --host=ia64-unknown-linux --prefix=/opt/gcc-pre3.1
--enable-languages=c++,java --enable-threads=posix --enable-parallel-mark
--disable-jvmpi

Disclaimers:

0) I believe the above ftp server doesn't allow you to enumerate
directories.   The files are there, even if it doesn't look like it.

1) The last tar file is meant to unpack to /opt/gcc-pre3.1.  You will need
write permission there.  You may want the -P flag for gtar.

2) This is at best alpha quality code.  It's based on a development version
of gcc, and there are still some Itanium specific bugs.  I didn't have much
luck with gcj -C in this version; the gij interpreter rejects some of the
generated class files.  Use your favorite Java to class compiler instead.
(This isn't needed if for normal gcj native code compilation.)  The current
stack unwinding code looks dubious to me, especially when exceptions are
thrown in interpreted code.  But the regression test results look credible,
and it seems to build and run SPECjbb (except for small sections of the
reporter) and some smaller tests.

3) You need glibc 2.2.4 to run any of the generated code.  This seems
unavoidable, since the development gcc relies on it.

4) You need a very recent version of binutils, such as the one included in
the last tar file.  (I've also had better luck with the version of gdb in
the tar file than with its predecessors.)

5) This version of gcc uses the new, official C++ vtable layout.  You should
not attempt to link against C++ code compiled by gcc 3.0.1 or earlier.  (The
ABI used for Java .o's differs from any other known version of gcj.  The
current official development and 3.0.2 trees are not usable for Java.)

6) The last tar file above includes C and C++ compilers.  These have been
tested only to the extent they were needed to build the Java runtime.


Hans

