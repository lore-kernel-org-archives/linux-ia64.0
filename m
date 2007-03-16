From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 16 Mar 2007 02:48:24 +0000
Subject: Re: [BUGFIX][PATCH] fixing placement of register stack under ulimit
Message-Id: <20070316114824.a1b3f715.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070315171743.e85b8405.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070315171743.e85b8405.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, dmosberger@gmail.com

plz allow me to explain more.

"Why register-stack/memory-stack upside down is bad" is a bit complicated.
So...this is a test and result for explaining bug. 

This is a sample code and its result on 2.6.21-rc3.
Note: base address of memory'stack can be randomly change.

= sample code =
[kamezawa@drpq ~]$ cat sample.c
#include <stdio.h>

void do_print(int num)
{
        if (num = 0)
                return;
        printf("%d\n",num);
        do_print(num - 1);
}

int main(int argc, char *argv[])
{
        do_print(10000);
        return 0;
}

= before ulimit =
[kamezawa@drpq ~]$ uname -a
Linux drpq 2.6.21-rc3 #3 SMP Fri Mar 16 11:57:47 JST 2007 ia64 ia64 ia64 GNU/Linux
[kamezawa@drpq ~]$ ulimit -s
8192
[kamezawa@drpq ~]$ ulimit -s -H
unlimited
[kamezawa@drpq ~]$ ./sample
10000
9999
....<snip>
1
[kamezawa@drpq ~]$
= after ulimit -s 8192 =

[kamezawa@drpq ~]$ ulimit -s
8192
[kamezawa@drpq ~]$ ulimit -s -H
8192
[kamezawa@drpq ~]$ ./sample  
10000
9999
....<snip>

9612
9611
9610
9609
9608
Segmentation fault

[kamezawa@drpq ~]$ ./sample   (when I'm lucky)
10000
9999
....<snip>
1
[kamezawa@drpq ~]$
==================
This number 9608 is too short to use up all stack. The reason of this is 
"ulimit -s + memory stack randomization + register-stack-expansion" is buggy.
The program can only use one page for register stack if unlucky.
My patch will fix this case.

-Kame








