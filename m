From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 05 Oct 2000 22:15:00 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test9)
Message-Id: <marc-linux-ia64-105590678205551@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 06 Oct 2000 09:08:33 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> The patch contains a deletion for unistd.h~ which is not in
  Keith> base 2.4.0-test9.

My fault, just ignore it (it was late, what can I say).

  Keith> It also deletes a lot of acpi files, which may cause problems
  Keith> if you try to compile ix86 from a source tree with
  Keith> ia64-001004 applied, i386 config.in does not have
  Keith> CONFIG_ACPI_KERNEL_CONFIG.  Any reason for these deletions
  Keith> and other acpi changes?

The ACPI code in the x86 tree is currently not compatible with what's
in the IA-64 tree.  So the IA-64 patch restores the ACPI files from
the IA-64 tree.  I don't know why or how this came to be and Intel is
looking into it.  (Yeah, it's a major pain...)

	--david

