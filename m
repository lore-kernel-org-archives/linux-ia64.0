From: Matt_Domsch@Dell.com
Date: Mon, 12 Mar 2001 22:29:07 +0000
Subject: [Linux-ia64] [PATCH] /proc access to EFI variables v0.02
Message-Id: <marc-linux-ia64-105590693005275@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've created a kernel patch which makes all the EFI variables available
under /proc/efi.  Support for reading, writing, creating, and destroying
variables is present.

I've incorporated feedback from Stephane Eranian (thanks!).
This patch is at version 0.02.  I've tested it myself, and believe it ready
for inclusion in David's tree.

Other changes include:
- exporting struct efi in kernel/ia64_ksyms.c so efivars can be a module
- setting the high bit on EFI error status codes in include/asm-ia64/efi.h
(per spec) (There's probably a cleaner way to do this.)


The patch is available at
http://domsch.com/linux/ia64/linux-2.4.1-010131-efivars-010312.patch, and is
also attached.

Reads to /proc/efi/varname return an efi_variable_t structure.
Writes to /proc/efi/varname must be an efi_variable_t structure.
Writes with DataSize = 0 or Attributes = 0 deletes the variable named in the
structure.  You should write to a different variable name file than the one
you are deleting (i.e., to delete Boot0000*, write to Boot0001*, with a name
of Boot0000 in the name field of the structure).  This avoids the problem of
deleting a /proc file while you are holding an open file handle to it.
Writes to any file with a new value in VariableName+VendorGuid creates a new
variable.

I haven't written a user-space app for manipulating the variables, but
that's necessary.  Or, you can cat one of the variables to a file, and use a
hex editor to change it, then cat it back.  That works well.

As always, your feedback is appreciated.

Thanks,
Matt

--
Matt Domsch
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux

