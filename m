From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 02 Aug 2001 03:38:40 +0000
Subject: [Linux-ia64] [RFC] /proc/ksyms change for IA64 (fwd)
Message-Id: <marc-linux-ia64-105590693005990@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

FYI.  Followups to linux-kernel@vger.kernel.org please, the initial
problem is IA64 specific but the fix is a generic one for all
architectures that require special processing, it needs to be discussed
on l-k.  I would have used Bcc: to ia64 but this list rejects Bcc mail.

------- Forwarded Message

The IA64 use of descriptors for function pointers has bitten ksymoops.
For those not familiar with IA64, &func points to a descriptor
containing { &code, &data_context }.  System.map contains the address
of the code, /proc/ksyms contains the address of the descriptor.
insmod needs the descriptor address, ksymoops and debuggers need the
code address, /proc/ksyms needs to contain both addresses, with one of
them prefixed by a special character.

EXPORT_SYMBOL() cannot distinguish between &function and &data.
Telling everybody that they must type EXPORT_SYMBOL_FUNCTION or
EXPORT_SYMBOL_DATA is not an option, the second symbol has to be
automatically added after linking vmlinux and modules.  I want to fix
this problem in user space, with no changes to to kernel code.  My
proposal for kernel 2.5 is :-

* In System.map and /proc/ksyms, label foo addresses the code, not the
  descriptor.  Label &foo addresses the function descriptor.

* foo has symbol versions, &foo does not.

* In kernel build, all objects that export symbols are post processed
  immediately after they are compiled.  On most architectures the post
  process is a no-op.  On IA64 it runs a program from modutils that
  identifies exported function pointers and modifies the ksymtab and
  kstrtab, see below.

* At run time, insmod does its normal address fixup processing first,
  including checking for symbol versions.  If the existing code
  succeeds without unresolved symbols, insmod modifies the address
  fixup so a reference to foo is resolved to &foo, iff both foo and
  &foo are in /proc/ksyms.

This has the benefit that all the changes are in modutils plus a small
change to the kernel build, no other user space tools are affected.
Most user space programs expect foo to address the code, not the
descriptor, AFAIK it is only insmod that needs the descriptor.  This
change will also affect any code that tries to front end functions from
modules but IMNSHO code should not be doing that.  If this breaks
binary only modules - tough.

One problem that always has to be addressed with modutils is version
skew between user space and the kernel.  With this approach, if you
build a new kernel with old modutils then the post processing program
will not be available so ksyms has the old format and the old insmod
behaviour applies, ksymoops will get errors but the kernel will still
run.  With a new modutils but an old kernel you get the old behaviour.
The only way you can get problems with version skew is to compile a
kernel on one machine with new modutils and install on another machine
with old modutils, modules will oops.  I don't see this as a problem,
the IA64 population is fairly small, in any case gcc cross compile for
IA64 has problems right now.

The new modutils supplied program (/usr/bin/modules_post) will look
through the __ksymtab section for an object.  For each exported symbol,
look at the data it references.  If that data contains two relocatable
addresses, one pointing to a text symbol, the other to a data symbol
and the text symbol has the same name as the exported symbol then this
is a descriptor.  Change the exported symbol name to &foo and add an
exported symbol foo that points to the code.

Note: This is modutils 2.5 stuff.  modules_post needs to use BFD which
      current modutils does not use, this adds a new requirement when
      compiling modutils.  Using BFD is the only way I can handle all
      the relocation types, especially in cross compile mode.  It may
      or may not get backported to modutils 2.4, probably not.
      ksymoops on IA64 2.4 will just have to live with lots of
      warnings.


------- End of Forwarded Message


