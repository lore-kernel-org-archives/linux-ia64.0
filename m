From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 07 May 2002 01:58:41 +0000
Subject: Re: [Linux-ia64] A Couple of Questions on 2.4.18
Message-Id: <marc-linux-ia64-105590701905552@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905551@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905551@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 6 May 2002 17:57:24 -0700, Alberto Munoz <amunoz@vmware.com> said:

  Alberto> Hello Everyone, I just upgraded my Linux kernel to 2.4.18
  Alberto> and have a couple of questions:

  Alberto> - I am having trouble dynamically loading NFS. It complains
  Alberto> about an unresolved external (memset). Poking around
  Alberto> through the IA64 files (ia64_ksyms.c) I noticed that memset
  Alberto> is no longer exported (as it was in 2.4.9), instead
  Alberto> __memset_generic is being exported. Is there anything I am
  Alberto> failing to do to get external modules to resolve memset to
  Alberto> __memset_generic?

  Alberto> - acpi.c (in arch/ia64/kernel) is forced to be included
  Alberto> with the IA64 kernel, but if one wants to run that kernel
  Alberto> on top of the SKI simulator (which does not have ACPI), the
  Alberto> kernel refuses to compile because some of the definitions
  Alberto> used by acpi.c are included under ifdefs (that are not
  Alberto> defined the configuration file for the SKI simulator, like
  Alberto> CONFIG_ACPI_BOOT and CONFIG_ACPI_PCI) in
  Alberto> include/linux/acp.h.

  Alberto> I have hacked my way around both of these problems, but I
  Alberto> would like to know if there are more elegant ways of
  Alberto> getting around them, or if I am entirely missing something.

Not really.  The next patch should have these problems fixed (due out
very soon).

	--david

