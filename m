From: Bill Nottingham <notting@redhat.com>
Date: Wed, 25 Oct 2000 18:15:40 +0000
Subject: [Linux-ia64] Re: CPU stepping in /proc/cpuinfo?
Message-Id: <marc-linux-ia64-105590678205628@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Francis Galiegue (fg@mandrakesoft.com) said: 
> Update: someone told me that revision in /proc/cpuinfo was what I was looking
> for. 0 means Ax stepping, 1 or more means Bx. Is this the case?

AFAIK:

   0 	=  Ax
   1	=  B0
   2	=  B1
   3	=  B2
...

Bill

