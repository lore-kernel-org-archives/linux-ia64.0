From: Dan Pop <Dan.Pop@cern.ch>
Date: Mon, 21 May 2001 14:14:49 +0000
Subject: Re: [Linux-ia64] How to use shared library on HP IA-64 Simulator
Message-Id: <marc-linux-ia64-105590693005632@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005630@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005630@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 21 May 2001, qiuhb wrote:

> When I used HP IA-64 Linux Developer's Kit, I entered into nue and typed
> 
> "gcc -o libtest.so  test.o  -lsnmp " and some errors happened such as
> "cant ld snmp,no such library".
> So I want to use snmp and newt,but I dont know how to put it to my
> program on nue environment.

Get into NUE, build and install these libraries and everyhting should
be fine.

Dan


