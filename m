From: Abhijit Kadlag <abhijit@csa.iisc.ernet.in>
Date: Tue, 26 Nov 2002 16:14:14 +0000
Subject: [Linux-ia64] linker
Message-Id: <marc-linux-ia64-105590709805484@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

i am trying to instrument the elf-binaries
on itanium. the task is to write a tool
like 'pixie' available on sgi machines.
 since i need to add counters for each basic block, which
have to be in memory, i need some way of referencing memory.
all i could find is itanium has only register indirect mode
of specifying memory address and then again loading
an address is done by the linker. i tried looking 
at the dis-assmebled code to discover how the linker
does the offset calculation, but i could not find
any correlation between program order of declaring
variables and their offsets , which are added to r1(gp).
 does it use the sections like .got or .plt in 
elf binary ? if yes, how ? 
  shall anyone please tell me , how to add instructions
to the binary of an executable,
which can specify the memory they want to 
access?
 

-- 
----------------------
Abhijit Kadlag
I sem ME,CSE,
Dept. of CSA,
IISc,Banagalore.


