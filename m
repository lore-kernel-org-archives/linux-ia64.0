From: Thomas Hiller <thomas.hiller@sap.com>
Date: Wed, 28 Mar 2001 08:09:58 +0000
Subject: [Linux-ia64] Error messages during link step
Message-Id: <marc-linux-ia64-105590693005360@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I get the following messages during linking:

Dwarf Error: Could not find abbrev number 51. (same message with other numbers)

abclib.o(.IA_64.unwind_info+0x51658): unsupported reloc

@gprel relocation against dynamic symbol rstrswbptr

What is the cause for this ?

I'm using:

GNU ld version 2.9-ia64-000717 (with BFD 2.9-ia64-000717)

gcc version 2.96-ia64-000717 snap 001117

Suse 20010309

Regards,

Thomas

--
Thomas Hiller                                           thomas.hiller@compaq.com
COMPAQ Computer Corporation                             thomas.hiller@sap.com
Global SAP Solution Center                              Tel: +49 6227 / 7-45426
LinuxLab @ SAP, Walldorf                                Fax: +49 6227 / 7-55426




