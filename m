From: Martin Pool <mbp@samba.org>
Date: Fri, 01 Aug 2003 01:54:10 +0000
Subject: Re: efibootmgr 0.4.2-test1
Message-Id: <marc-linux-ia64-105970299504064@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105967815211635@msgid-missing>
In-Reply-To: <marc-linux-ia64-105967815211635@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 31 Jul 2003, Matt_Domsch@Dell.com wrote:
> Announcing efibootmgr 0.4.2-test1.  If you have systems you can test
> this on, please do so.

It seems to work in brief tests on an rx2600 with Debian stable and
2.5.72.

Perhaps you could provide a bit more context in the introduction to
help people new to the platform?  Perhaps something like this:

cd ~/work/efibootmgr/efibootmgr-0.4.2-test1/src/man/man8/
diff -u -p /home/mbp/work/efibootmgr/efibootmgr-0.4.2-test1/src/man/man8/efibootmgr.8.docbook.orig /home/mbp/work/efibootmgr/efibootmgr-0.4.2-test1/src/man/man8/efibootmgr.8.docbook
--- /home/mbp/work/efibootmgr/efibootmgr-0.4.2-test1/src/man/man8/efibootmgr.8.docbook.orig	2002-04-06 13:46:54.000000000 +1000
+++ /home/mbp/work/efibootmgr/efibootmgr-0.4.2-test1/src/man/man8/efibootmgr.8.docbook	2003-08-01 11:52:21.000000000 +1000
@@ -92,11 +92,11 @@
     
     <note>
       <para>
-        &manpackage; requires that the kernel module efivars be loaded 
-        prior to use.  <command>'modprobe efivars'</command> should do the trick.
+        &manpackage; requires that the kernel support access to EFI
+        non-volatile variables (through <filename>/proc/efi/vars</filename>).
+        <command>'modprobe efivars'</command> should do the trick.
       </para>
     </note>
-
   </refsect1>
   <refsect1>
     <title>OPTIONS</title>

Diff finished at Fri Aug  1 11:53:10


Regards,
-- 
Martin 
