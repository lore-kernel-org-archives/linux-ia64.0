From: Brian Sumner <bls@sgi.com>
Date: Thu, 13 Sep 2001 19:11:02 +0000
Subject: Re: [Linux-ia64] Issue with using execlp() from a 32 bit binary on IA64
Message-Id: <marc-linux-ia64-105590698805177@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Venkatesh Ramamurthy wrote:
> 
> Hi,
> The RAID group has a problem with using execlp function from a 32bit binary.

A quick glance at the source indicates a bug in glibc 2.2.3 execl
and execlp if you pass more than 1024 arguments.  Strangely, the
execle function is OK.  (Compare the last argument to the memcpy
calls in posix/execl.c and posix/execle.c)

Brian Sumner

