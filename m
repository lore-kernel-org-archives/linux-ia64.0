From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 03 Feb 2003 19:19:29 +0000
Subject: Re: [Linux-ia64] Question about .opd section
Message-Id: <marc-linux-ia64-105590709805799@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805798@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805798@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 3 Feb 2003 08:37:48 -0800, "Wichmann, Mats D" <mats.d.wichmann@intel.com> said:

  Mats> The gnu toolchain (well, binutils) emits a .opd section
  Mats> for  architectures which use function descriptors -
  Mats> it's not unique to Itanium.

As far as I know, this is an HPism (originally coming from HP-UX
PA-RISC).  "opd" stands for "official procedure descriptor".  the
"official" is in the sense that the address of each descriptor serves
as the canonical "address" of the function it's describing; i.e., this
is what makes function-pointer comparisons work.

  Mats> But I can't find much information about it.  Google has been
  Mats> unhelpful (to me, anyway) on this one. It's described as
  Mats> holding function descriptors, but I'm not clear who uses this
  Mats> information - is this used at runtime?

Nothing at run-time directly references the .opd section, but of
course whenever you call a function through a pointer, you'll end up
loading the function's global-pointer and it's entry point from a
descriptor.  The main program's descriptor are stored in .opd (for
shared objects, the function descriptors are created at runtime, by
the runtime loader).

  Mats> Is this section considered normal/required for
  Mats> Linux/ia64?  I'm asking because it wasn't in the
  Mats> Itanium psABI, and thus didn't make it into the
  Mats> current version of the Itanium LSB spec; our
  Mats> application checker tool is flagging this as an
  Mats> unknown section.

It might be good to document it in the LSB.  There might be tools out
there that assume that .opd contains nothing but function descriptors,
so if someone put something else in there, things might go wrong badly
(which reeminds me: the ptrace-support in libunwind accesses .opd as a
fallback-mechanism to determine the global-pointer of the main
program; so there is at least one library out there that would break
if .opd contained other stuff).

	--david

