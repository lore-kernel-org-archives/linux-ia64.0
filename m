From: Bill Nottingham <notting@redhat.com>
Date: Thu, 26 Apr 2001 15:03:13 +0000
Subject: [Linux-ia64] Re: malloc problems
Message-Id: <marc-linux-ia64-105590693005474@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Donny Cooper (dcooper@hstc.necsyl.com) said: 
> dynamic_area = (unsigned char *) malloc ( membytes );
> printf(" dyn_area = %x %lx, mem= %x \n",dynamic_area,dynamic_area,membytes);
> 
> Result from Tom: (1-way BigSur)
> dyn_area = 40000010 40000010, mem= 2000018

It looks like you forgot a prototype for malloc.

Bill

