From: Bill Nottingham <notting@redhat.com>
Date: Fri, 14 Sep 2001 14:41:10 +0000
Subject: [Linux-ia64] Re: Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805182@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Doug Beattie (dbb@caldera.com) said: 
> `The /lib directory on x86 and IA64 will always contain the 32bit
> libraries. IA64 systems should put their libraries in /lib64.' "This
> way we don't need any special install hooks in the system, installer,
> and package. It's all hardcoded." 

That doesn't make sense to me. For the dlopen()ing of things we're talking
about, the reasons they are hardcoded paths is because *they are not in
the standard library search path*.

Bill

