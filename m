From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Fri, 03 Mar 2000 18:21:09 +0000
Subject: Re: [Linux-ia64] ELI now on sourceforge
Message-Id: <marc-linux-ia64-105590678204976@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 03, 2000, Andreas Schwab <schwab@suse.de> wrote:
> Johannes Erdfelt <jerdfelt@valinux.com> writes:
> 
> |> I've taken ELI and created a project on sourceforge.net for it.
> |> 
> |> ELI is a boot loader for EFI based systems. It was developed for, and
> |> currently only works for, Linux on ia64 systems.
> |> 
> |> I've also made a new release which mostly cleans up the allocations
> |> before exiting. It's not finished yet, for instance, ACPI data isn't
> |> freed yet, but will come soon.
> 
> I couldn't get this to compile: FPSWA_PROTOCOL is undefined.  Where and
> how is this supposed to be defined?

I had defined it in my gnu-efi/inc/efiprot.h file.

I forgot I had done that, but that raises the question where is this
supposed to be defined?

But, for right now, this patch will work:

--- eli.h.orig	Fri Mar  3 10:18:25 2000
+++ eli.h	Fri Mar  3 10:18:46 2000
@@ -1,6 +1,14 @@
 #ifndef lilo_h
 #define lilo_h
 
+#ifndef FPSWA_PROTOCOL
+/*
+ *  FPSWA library protocol
+ */
+#define FPSWA_PROTOCOL \
+	{ 0xc41b6531, 0x97b9, 0x11d3, {0x9a, 0x29, 0x0, 0x90, 0x27, 0x3f, 0xc1, 0x4d }}
+#endif
+
 static inline EFI_STATUS
 check_abort(EFI_SYSTEM_TABLE *systab)
 {

I've checked this in already to CVS

JE



