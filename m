From: Christoph Rohland <cr@sap.com>
Date: Wed, 26 Apr 2000 14:09:48 +0000
Subject: [Linux-ia64] ld failure
Message-Id: <marc-linux-ia64-105590678205047@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

On finally linking a _very_ big executable I get:

/usr/bin/ld: Dwarf Error: Could not find abbrev number 110.
/usr/bin/ld: Dwarf Error: Could not find abbrev number 117.
/usr/bin/ld: Dwarf Error: Could not find abbrev number 5392.
/usr/lib/gcc-lib/ia64-cygnus-linux/2.9-ia64-000216/crtbegin.o(.fini+0x2): relocation truncated to fit: PCREL21B fini
collect2: ld returned 1 exit status   

Any help appreciated

        Christoph


