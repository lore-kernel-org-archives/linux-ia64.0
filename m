From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 25 Sep 2002 23:29:57 +0000
Subject: RE: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906068@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 25 Sep 2002 12:40:20 -0700, "Wichmann, Mats D" <mats.d.wichmann@intel.com> said:

  Mats> Ahem.  I'm listening.  There's a draft ia64 LSB spec available
  Mats> for review here:

  Mats> http://www.linuxbase.org/spec/lsbia64review.html

  Mats> you can also go directly to the doc from here:

  Mats> http://www.linuxbase.org/spec/index.shtml

  Mats> (and file bugs in the normal way through sourceforge, which is
  Mats> better, since if you're logged in when you file it you get
  Mats> notifications back as it progresses).

In the ELF header flags, I didn't see any mention of this bit:

/* Least-significant four bits of ELF header's e_flags are
   OS-specific.  The bits are interpreted as follows by Linux: */
#define EF_IA_64_LINUX_EXECUTABLE_STACK 0x1 /* is stack (& heap) executable by default? */

Might be worthwhile to document it, since it is ia64 linux specific
and hence not mentioned in the ABI.

  Mats> The /emul/linux-i386 stuff is a path prefix supplied by the
  Mats> kernel, right?  I really don't know whether that should be
  Mats> mentioned in the spec or not: does an application actually
  Mats> need to know that this is happening, or is it completely
  Mats> transparent?  Of course a given system has to "get it right".

Right, /emul/ia32-linux/ is a kernel thing.  I agree it doesn't make
much sense to describe the mechanism.  However, perhaps you might want
to document what "uname -m" ought to return when exec'd from an x86
binary.  (Where does this document talk about x86 support anyhow?)

  Mats> One thing that's been batted around is the name of the dynamic
  Mats> linker: it's been tentatively called ld-lsb-ia64.so.1 to
  Mats> parallel the "standard" Linux one, but other folks with 64-bit
  Mats> architectures prefer a more generic ld-lsb-64.so.1, which
  Mats> would be the same name regardless of architecture.  Since this
  Mats> doesn't affect ld-linux, there's no backwards-compatibility
  Mats> issue with that name...

That's a stupid idea.  The dynamic loader is the _one_ thing that's
very difficult to emulate when hosting an OS environment on a guest
OS.  The only clean way to avoid that is to give each loader a unique
name.  ld-lsb-$(uname -m).so.1 probably would be more reasonable
(assuming LSB has a VERY good reason why ld-linux-$(uname -m).so.1
isn't good enough).

Think of what would happen if you wanted to, say, emulate SPARC64
Linux binaries on an Itanium platform.  If both SPARC64 and ia64 linux
used /lib/ld-lsb-64.so.1, you'd find yourself in big trouble (and no,
the /emul/xxx-prefix doesn't help here either; it's a bootstrapping
problem...).

	--david

