From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Tue, 27 Feb 2001 01:16:00 +0000
Subject: [Linux-ia64] gcj build on Itanium
Message-Id: <marc-linux-ia64-105590693005213@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I attempted to build gcc (roughly CVS version, as of about a week ago),
including the java support, on a machine with the 11/17 tool chain
installed.  I had successfully built gcj on Itanium a long time ago.  But
there seems to have been some bit rot.

I've gotten to the point where I can again barely run the hello world
program.  I'm still working on making this usable again.  But I ran into a
number of problems for which I would have trouble generating a proper patch
without some help.  And some of them look like they might have implications
for other things.  So here's a list of what I've run into so far:

Problem 1: java/jcf-io.c in the Java front end is misoptimized by the 11/17
compiler.  The problem appears to be with the inlined strcpy call in
find_class.

Workaround: Don't optimize it.  (This is probably not worth fixing unless
it's still broken in the CVS toolchain, which I haven't checked.)

Problem 2: The build process had trouble finding the libgcc_s.so.0 it just
built.

Workaround: I hacked in the right linker option.

Request: Could someone fix this properly, if it is indeed just a build
problem.

Problem 3: Finally clauses are now miscompiled by the Itanium gcj.  The code
generates references to undefined labels, as in "addl r14=@ltoff(.L837),gp"
with no definition of .L837.

Workaround: I temporarily removed the offending "finally" clauses from
ObjectInputStream.java and ObjectOutputStream.java.  This allows Java
programs to link at a minor cost in correctness :-) .

Request: Could someone who understands gcc exception handling check that
exception handling is configured sanely for Java?  I suspect that Java uses
setjmp/longjmp exception handling, which is different from C++, and probably
wrong.  Why does setjmp/longjmp excetpion handling result in incorrect code
for try/finally?

Problem 4: Linking Java applications dynamically results in "@gprel
relocation against dynamic symbol java::lang::System::out".  As far as I can
tell, java/lang/System.java defines the symbol, and is compiled with -fPIC.

Question: Should the fron end be doing something it isn't in order to deal
with sdata symbols?  Is -fPIC different from -fpic on Itanium?

Problem 5: Static linking tends to result in "eh.o...: undefined reference
to `fwrite'.  This seems to be a library ordering problem, which might also
affect other platforms.

Workaround: use "-u fwrite" on the command line.

Request: What's a proper fix?

Problem 6: -save-temps doesn't save the main program .o file.  This seems
like an oversight, which is mildly annoying when debugging gcj.

Request: A fix? (low priority)

Problem 7: Generated executables die imeediately in the garbage collector,
since the main process stack location is no longer at the fixed location
hardcoded into the GC for Itanium.  (This was a kernel change from a few
months ago.)

Patch: (Don't use with NUE simulator.)
Index: gcconfig.h
=================================RCS file: /cvs/gcc/gcc/boehm-gc/gcconfig.h,v
retrieving revision 1.15
diff -u -r1.15 gcconfig.h
--- gcconfig.h	2000/12/10 22:57:37	1.15
+++ gcconfig.h	2001/02/27 01:05:22
@@ -1116,11 +1116,20 @@
 #       define CPP_WORDSZ 64
 	/* This should really be done through /proc, but that	*/
 	/* requires we run on an IA64 kernel.			*/
-#       define STACKBOTTOM ((ptr_t) 0xa000000000000000l)
+	/* The following works on old NUE and older kernels:	*/
+/* #       define STACKBOTTOM ((ptr_t) 0xa000000000000000l)	*/
+	/* This does not work on NUE:				*/
+#       define LINUX_STACKBOTTOM
 	/* We also need the base address of the register stack	*/
-	/* backing store.  There is probably a better way to	*/
-	/* get that, too ...					*/
-#	define BACKING_STORE_BASE ((ptr_t) 0x9fffffff80000000l)
+	/* backing store.  There should be a better way to get	*/
+	/* this:						*/
+#	define APPROX_BS_BASE ((word)GC_stackbottom-0x80000000)
+	/* We round to the next multiple of 1 MB, to compensate	*/
+	/* for the fact that the stack base is displaced by	*/
+	/* the environment, etc.				*/
+#	define BACKING_STORE_BASE \
+		(ptr_t)((APPROX_BS_BASE + 0xfffff) & ~0xfffff)
+
 #	if 1
 #	    define SEARCH_FOR_DATA_START
 #	    define DATASTART GC_data_start


