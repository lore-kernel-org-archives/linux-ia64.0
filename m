From: SCHAN@uk.ibm.com
Date: Fri, 15 Sep 2000 15:17:55 +0000
Subject: [Linux-ia64] setjmp/longjmp : flushing register stack
Message-Id: <marc-linux-ia64-105590678205495@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hello,

We are developing the Linux/IA64 Java VM and we need sigsetjmp/setjmp
flushing the register stack properly - however currently it only flush on
the call of longjmp - is there any chance of adding flushrs into
setjmp/sigsetjmp? We could do it in our code but there will be rather
inconvenient...

-x-
Sunny Chan
Java Technology Center,
Mail Point 146, IBM UK, Hursley Park, Winchester, England SO21 2JN

Notes ID: Sunny Chan/UK/IBM
Email: schan@uk.ibm.com
Telephones: Internal: 246762 External: 01962 816762 Mobile: 07887-704088



