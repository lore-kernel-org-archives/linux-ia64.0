From: Petur Thors <peturth@hi.is>
Date: Thu, 06 Mar 2003 13:41:20 +0000
Subject: [Linux-ia64] compiling 2.5.60 on hp simulator
Message-Id: <marc-linux-ia64-105590709805984@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello list.
I'm having trouble compiling kernel 2.5.60 on the hp-simulator. I'm 
using the
latest(ski version 0943l) IA-64 Linux Developers Kit from the CD. After 
make menuconfig (in
the nue enviroment) I do make and the Makefile from arch/ia64 tells me
that I have to update my gas (as --version = 2.9-ia64-000717).
So I update it from the URL given by the Makefile and try again. Then i get
gas message: error file number less then one. (from 
arch/ia64/tools/print_offsets)
I also tried using the lastest binutils from gnu compiled with 
target=ia64-hp-linux and
got the same error message.
If you have ANY thoughts or ideas about what to do (maybe update the 
whole toolchain, gcc , etc)
it would be most welcome. If this is a utterly braindead question i 
apologies for waisting your time.
Thank you
Petur


