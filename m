From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Date: Mon, 12 Nov 2001 08:15:53 +0000
Subject: [Linux-ia64] Pagesize is different between IA32 and IA64
Message-Id: <marc-linux-ia64-105590698805465@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 Hello all.

 If this problem has already known, I am sorry.

 I am investigating the problem that calloc returns no
 cleared area.
 It was made on IA32 system and executes on IA64.
 I think calloc expects to clear the memories sbrk
 returned. But When the program made on IA32 is
 executing on IA64 system, sbrk sometimes returns no
 cleared area. 
 Because the Kernel on IA64 alignes the memories 16K
 bytes. However, when the progmam made on IA32 is
 executing on IA64, the function __getpagesize returns
 4Kbytes. At this case, if the memories that calloc
 requests to return sbrk(-xxx) is smaller than
 16Kbytes, the kernel do not unmap this memory.
 (I think that the time that the memories clears 0 by
 the kernel is when the kernel maps memories by the signal) 

 How do you think?

--
Regards, 
Hideki Yamamoto   (V).v.(V) # Empowered by Innovation


