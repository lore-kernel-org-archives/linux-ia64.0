From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 08 May 2003 00:13:06 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705666@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 7 May 2003 16:51:21 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>How many tools are out there that depend on System.map or similar?  I
>suppose you could just generate a fresh System.map at boot time (or
>have something like /proc/System.map).

ksymoops (user space), kdb, kksymoops (kernel).

Both kdb and kksymoops are specifically designed to not use
relocations, they store kernel addresses as absolute numbers.  Not that
big a deal, ia64 setup can run the kallsyms tables at boot time and
relocate them.

ksymoops in user space is a bigger problem, it reads System.map.
Fixing user space will be a problem.  OTOH, the function descriptor
problem in ia64 means that ksymoops in user space gets thousands of
address mismatches between System.map and /proc/ksyms so ksymoops is
not used very much for ia64.


