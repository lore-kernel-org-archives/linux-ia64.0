From: Grant Grundler <iod00d@hp.com>
Date: Thu, 16 Oct 2003 18:32:06 +0000
Subject: BUG 2.4.23-pre6 megaraid2 fails to build
Message-Id: <marc-linux-ia64-106632918018841@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

FYI, In case anyone cares about megaraid2, it fails to build for ia64
from bjorns linux-ia64-2.4 bk tree. I've got too many other things
to chase this now.

...
gcc -D__KERNEL__ -I/usr/src/linux-ia64-2.4/include -Wall -Wstrict-prototype=
s -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common -g -fomit-frame-point=
er -pipe  -ffixed-r13 -mfixed-range=F12-f15,f32-f127 -falign-functions2 -DG=
AS_HAS_HINT_INSN -frename-registers --param max-inline-insnsP00 -DMODULE -D=
MODVERSIONS -include /usr/src/linux-ia64-2.4/include/linux/modversions.h  -=
nostdinc -iwithprefix include -DKBUILD_BASENAME=3Dmegaraid2  -c -o megaraid=
2.o megaraid2.c
megaraid2.c: In function `mega_find_card':
megaraid2.c:403: error: structure has no member named `lock'
megaraid2.c: In function `megaraid_iombox_ack_sequence':
...

grant
