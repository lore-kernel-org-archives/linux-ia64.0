From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 08 Apr 2004 15:32:34 +0000
Subject: Re: local symbol 0: discarded in section `.exit.text' from drivers/built-in.o
Message-Id: <200404080832.34850.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_SCXdAkEMLySHPPl"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040408003018.42418a33.akpm@osdl.org>
In-Reply-To: <20040408003018.42418a33.akpm@osdl.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_SCXdAkEMLySHPPl
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday, April 8, 2004 12:30 am, Andrew Morton wrote:
> Also, I am heartily sick of this gunk from the assembler:
>
> {standard input}:20882: Warning: This is the location of the conflicting
> usage  {standard input}:20917: Warning: Use of 'ld4' may violate RAW
> dependency 'DBR#' (data) {standard input}:20917: Warning: Only the first
> path encountering the conflict is reported {standard input}:20882: Warning:
> This is the location of the conflicting usage {standard input}:20917:
> Warning: Use of 'ld4' may violate RAW dependency 'DBR#' (data)
>
> Has that been fixed yet?  If so, which is a good version of binutils to
> start using?

H.J. said he'd fix it when he had time, I think it involves a rewrite of the 
dependency checking code in binutils.  I ended up compiling binutils with 
this hack to avoid the checks altogether.

Jesse


--Boundary-00=_SCXdAkEMLySHPPl
Content-Type: text/plain;
  charset="iso-8859-1";
  name="binutils-nodvcheck.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="binutils-nodvcheck.patch"

--- binutils-2.14.90.0.8.orig/gas/config/tc-ia64.c	Wed Jan 14 13:07:45 2004
+++ binutils-2.14.90.0.8/gas/config/tc-ia64.c	Wed Jan 14 15:02:24 2004
@@ -6452,11 +6452,11 @@
 
     case 'x':
       /* -X conflicts with an ignored option, use -x instead */
-      md.detect_dv = 1;
+      md.detect_dv = 0;
       if (!arg || strcmp (arg, "explicit") == 0)
 	{
 	  /* set default mode to explicit */
-	  md.default_explicit_mode = 1;
+	  md.default_explicit_mode = 0;
 	  break;
 	}
       else if (strcmp (arg, "auto") == 0)

--Boundary-00=_SCXdAkEMLySHPPl--
