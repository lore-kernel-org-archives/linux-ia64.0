From: roneng@ca.ibm.com
Date: Thu, 06 Apr 2000 13:25:33 +0000
Subject: [Linux-ia64] Tool chain ld program -Previous message incomplete
Message-Id: <marc-linux-ia64-105590678205003@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



I sent the previous email before it was complete by mistake
here is the complete version

I've been using the ld program in the Turbo linux distribution to build a
large (96Meg) shared library. The link seems
to be failing with Reallocation error.
To fix this problem I recompile the ld program in the Tool chain sources
from Cygnus with the following modification to
MAXPAGESIZE parameter in the
ld/emulparams/elf64_ia64.sh
originally the file had MAXPAGESIZE =0x10000
I modified this to MAXPAGESIZE = 0x10000000

The changed.Cygnus file shows that this parameter was changed on 1999-11-06
by cygnus from 0x10000000 to 0x10000,
which was the original value was wondering if anyone knew why this changed
occurred, and if undoing the change is I did will
cause any problems?

Thank you,
Ronen Grosman
- Phone: Internal:778-4478     External: (416)-448-4478    Fax:
(416)448-4414
- e-mail roneng@ca.ibm.com


---------------------- Forwarded by Ronen Grosman/Toronto/IBM on 04/06/2000
09:22 AM ---------------------------

Ronen Grosman
04/06/2000 09:11 AM

To:   linux-ia64@linuxia64.org
cc:
From: Ronen Grosman/Toronto/IBM@IBMCA
Subject:  Tool chain ld program



I've been using the ld program in the Turbo linux distribution to build a
large (96Meg) shared library. The link seems
to be failing with Realocation error.
To fix the program I recompile the ld program in the Tool chain sources
from Cygnus with the following modification to
MAXPAGESIZE parameter in the
ld/emulparams/elf64_ia64.sh
originally the file had MAXPAGESIZE =0x10000
I modified this to MAXPAGESIZE = 0x10000000

In Changed

Ronen Grosman
- Phone: Internal:778-4478     External: (416)-448-4478    Fax:
(416)448-4414
- e-mail roneng@ca.ibm.com






