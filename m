From: Bryce McKinlay <bryce@albatross.co.nz>
Date: Tue, 27 Feb 2001 09:37:20 +0000
Subject: [Linux-ia64] gcj static linking fix [Re: gcj build on Itanium]
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------8E5E6652B1740475F705EED2"
Message-Id: <marc-linux-ia64-105590693005216@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------8E5E6652B1740475F705EED2
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

"Boehm, Hans" wrote:

> Problem 5: Static linking tends to result in "eh.o...: undefined reference
> to `fwrite'.  This seems to be a library ordering problem, which might also
> affect other platforms.
>
> Workaround: use "-u fwrite" on the command line.
>
> Request: What's a proper fix?

Static libgcc linking seems to require "-lgcc -lc -lgcc" with no other
libraries in between in order to work correctly. The use of libgcj.spec was
adding additional libraries between the first "-lgcc" and the "-lc". This patch
fixes it. I'm checking it in to head + branch.

regards

  [ bryce ]



--------------8E5E6652B1740475F705EED2
Content-Type: text/plain; charset=us-ascii;
 name="libgcj.spec.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="libgcj.spec.patch"

2001-02-27  Bryce McKinlay  <bryce@albatross.co.nz>

	* libgcj.spec.in: Insert %(libgcc) before %(liborig) to fix static
	linking.

Index: libgcj.spec.in
===================================================================
RCS file: /cvs/gcc/egcs/libjava/libgcj.spec.in,v
retrieving revision 1.13
diff -u -r1.13 libgcj.spec.in
--- libgcj.spec.in	2001/02/05 05:46:16	1.13
+++ libgcj.spec.in	2001/02/27 09:27:45
@@ -4,7 +4,7 @@
 # to link with libgcj.
 #
 %rename lib liborig
-*lib: -lgcj -lm @GCSPEC@ @THREADSPEC@ @ZLIBSPEC@ @SYSTEMSPEC@ %(liborig)
+*lib: -lgcj -lm @GCSPEC@ @THREADSPEC@ @ZLIBSPEC@ @SYSTEMSPEC@ %(libgcc) %(liborig)
 
 *jc1:  @DIVIDESPEC@ @EXCEPTIONSPEC@ @JC1GCSPEC@ -fasynchronous-exceptions
 

--------------8E5E6652B1740475F705EED2--


