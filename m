From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Tue, 10 Apr 2001 03:11:20 +0000
Subject: [Linux-ia64] strace / ptrace_offsets.h
Message-Id: <marc-linux-ia64-105590693005384@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello everyone!

I've just found this message from Uros in the mailing list
archive:

> I am trying to compile strace under 2.4.0-test6 and I missing symbols
> for PT_K_B0, PT_K_AR_PFS, PT_K_AR_UNAT, PT_K_AR_RNAT, PT_K_AR_BSPSTORE,
> PT_K_PR and PT_CR_IFS.  I have
> sucessfully compiled the same source under 2.3.99-pre6 kernel headers.
> 
> Symbol PT_CR_IFS was replaced with PT_CFM; this is a problem with strace
> source.  However, the other symbols disappeared from ptrace_offsets.h.
> I don't recall any patches against ptrace interface lately.  Is this a
> lossage in kernel headers?

Unfortunately, I haven't found any answeres to this post.

This problem seems to be back with strace 4.3 and kernel 2.4.3. In this
case, which one should be fixed??

Thanks!!

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

