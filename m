From: SCHAN@uk.ibm.com
Date: Tue, 08 Aug 2000 15:18:19 +0000
Subject: [Linux-ia64] makecontext/swapcontext/getcontext
Message-Id: <marc-linux-ia64-105590678205274@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hello,

     Is there any plan to implement the context management functions
(makecontext/ swapcontext/ getcontext - specified in UNIX95/98) in glibc
for ia64? We need those functions for the programs we are porting and
currently those functions exist in the glibc as stubs (return ENOSYS). Is
there any equivant functions exist in the glibc/kernel which do the same
job?

     Thanks!


-x-
Sunny Chan
Java Technology Center,
Mail Point 146, IBM UK, Hursley Park, Winchester, England SO21 2JN

Notes ID: Sunny Chan/UK/IBM
Email: schan@uk.ibm.com
Telephones: Internal: 246762 External: 01962 816762 Mobile: 07887-704088



