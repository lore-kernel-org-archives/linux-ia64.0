From: roneng@ca.ibm.com
Date: Thu, 06 Apr 2000 13:11:28 +0000
Subject: [Linux-ia64] Tool chain ld program
Message-Id: <marc-linux-ia64-105590678205002@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



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




