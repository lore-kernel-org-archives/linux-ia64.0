From: Alberto Munoz <amunoz@vmware.com>
Date: Tue, 07 May 2002 00:57:24 +0000
Subject: [Linux-ia64] A Couple of Questions on 2.4.18
Message-Id: <marc-linux-ia64-105590701905551@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Everyone,

I just upgraded my Linux kernel to 2.4.18 and have a couple of questions:

- I am having trouble dynamically loading NFS. It complains about an
unresolved external (memset). Poking around through the IA64 files
(ia64_ksyms.c) I noticed that memset is no longer exported (as it was in
2.4.9), instead __memset_generic is being exported. Is there anything I am
failing to do to get external modules to resolve memset to __memset_generic?

- acpi.c (in arch/ia64/kernel) is forced to be included with the IA64
kernel, but if one wants to run that kernel on top of the SKI simulator
(which does not have ACPI), the kernel refuses to compile because some of
the definitions used by acpi.c are included under ifdefs (that are not
defined  the configuration file for the SKI simulator, like CONFIG_ACPI_BOOT
and CONFIG_ACPI_PCI) in  include/linux/acp.h.

I have hacked my way around both of these problems, but I would like to know
if there are more elegant ways of getting around them, or if I am entirely
missing something.

Any help would be greatly appreciated.

Bert Munoz


