From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 17 Apr 2003 21:12:40 +0000
Subject: RE: [Linux-ia64] floating-point error
Message-Id: <marc-linux-ia64-105590723705552@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705538@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oracle has its own exception handler.  It usually dumps out more
information in its alert file.  Look in $ORACLE_HOME/rdbms/log/*.log for
more clue.

- Ken

-----Original Message-----
From: Luck, Tony 
Sent: Thursday, April 17, 2003 1:40 PM
To: Bruno Cornec; linux-ia64@linuxia64.org
Cc: martin@ojf.com; klaus.grupe@hp.com; emmanuel.avrillon@hp.com
Subject: RE: [Linux-ia64] floating-point error

> Sometimes the Oracle process dies with the following error message:
> 
> Apr 17 20:24:48 rx1 kernel: oracle(7148): floating-point assist fault
at ip 40000000048b4562
> 
> The ip address is always the same. This happens on all of our 4 nodes
> as it seems randomly. I do not have other debug info as this is the
only
> message printed. Some times for the same process the message is
printed 
> up to 4 times.

Are you certain that the message is related to the death of the process?

This message is a warning to let you know that your application has run
into
one of the corner cases of IEEE floating point that is not implemented
in
hardware by the processor (typically operations involving denormalized
numbers
will cause this, but there may be other cases). There is rate limiting
code in
the kernel to prevent this message from flooding the logs (and from
becoming
even more of a performance drag than taking a trap and emulating in
s/w).

It is relatively normal to see this message (even multiple times from
the
same process), and it usually isn't fatal.

-Tony Luck

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

