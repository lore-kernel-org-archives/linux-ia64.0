From: <shamc@ufrima.imag.fr>
Date: Fri, 02 Aug 2002 08:05:28 +0000
Subject: [Linux-ia64] Help for OpenGFS
Message-Id: <marc-linux-ia64-105590701905883@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi:

    Since last week,I've tried to install the file system OpenGfs in IA 64,
however the source didn't get compiled. In fact, it exists 2 patches
different: -one for the kernel 2.4.17 adapted IA 64     
           -one for the source of OpenGfs adapted to the kernel 2.4.17

It seems that these two patches have some conflits between them: for example,
there is redefinition of "semaphore.h" in the first patch. 

Has anyone ever installed Open Gfs in IA 64 ? Or ever faced to the similar
problem, please help me or send me a mail:


  shamc@ufrima.imag.fr


