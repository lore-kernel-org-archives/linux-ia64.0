From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Jul 2002 16:25:59 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] arch/ia64/tools/Makefile
Message-Id: <marc-linux-ia64-105590701905837@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905829@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905829@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Shouldn't "mrproper" simply have a dependency on "clean"?

	--david

>>>>> On Wed, 24 Jul 2002 07:20:08 -0700, "David N. Lombard" <david.lombard@mscsoftware.com> said:

  David.L> sigh...  The earlier arch/ia64/tools/Makefile patch
  David.L> replicated the action for both targets -- a redundant
  David.L> action.

  David.L> Attached is the file I intended to send.

  David.L> David N. Lombard wrote:
  >> The arch/ia64/tools/Makefile has an empty action for the mrproper
  >> target.  The result is that arch/ia64/tools/print_offsets.s,
  >> arch/ia64/tools/print_offsets, and arch/ia64/tools/offsets.h
  >> remain after a "make mrproper".  The files are deleted with "make
  >> distclean".
  >> 
  >> So, this could be a (subtle) intended difference between the
  >> mrproper and distclean targets, but that seems unlikely.
  >> 
  >> The attached patch moves the file deletion from the clean target
  >> (invoked via distclean) to the mrproper target; the distclean
  >> target still results in the files being deleted.

  David.L> -- David N. Lombard MSC.Software ---
  David.L> arch/ia64/tools/Makefile.orig Tue Jul 23 17:01:41 2002 +++
  David.L> arch/ia64/tools/Makefile Tue Jul 23 17:01:55 2002 @@ -5,9
  David.L> +5,9 @@ all:
 
  David.L>  mrproper: + rm -f print_offsets.s print_offsets offsets.h
 
  David.L>  clean: - rm -f print_offsets.s print_offsets offsets.h
 
  David.L>  fastdep: offsets.h @if ! cmp -s offsets.h ${TARGET}; then
  David.L> \

