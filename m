From: "Marc Eshel" <eshel@almaden.ibm.com>
Date: Thu, 14 Dec 2000 06:38:33 +0000
Subject: [Linux-ia64] gdb on ia64
Message-Id: <marc-linux-ia64-105590678205835@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,
Can any one explain why gdb on ia64 tries to attach (and gets an error) to
a process that died with a sigsegv
even when I start it with the --core option, giving it a core dump.
I am using TurboLinux IA-64 Beta 2, with  egcs-core-20001002  and
egcs-g++-20001002.
Thanks, Marc.


