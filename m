From: Xavier Leroy <xavier.leroy@inria.fr>
Date: Tue, 13 Nov 2001 20:42:00 +0000
Subject: [Linux-ia64] Re: PTHREAD_PROCESS_SHARED not supported
Message-Id: <marc-linux-ia64-105590698805499@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Current version of libpthread (libpthread-0.9.so based on glibc-2.2.3) 
> provided with RH 7.1 distribution do not support
>   PTHREAD_PROCESS_SHARED flag; pthread_mutexattr_setpshared(&mutatr,
>   PTHREAD_PROCESS_SHARED) returns ENOSYS.
> 
> Does a patch exist that implements it or are they plans to do that ?

Briefly: no, and no.  For more information, please refer to question E.7
of the LinuxThreads FAQ, 
        http://pauillac.inria.fr/~xleroy/linuxthreads/faq.html

Regards,

- Xavier Leroy

