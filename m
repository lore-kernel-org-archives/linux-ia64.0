From: Dan Pop <Dan.Pop@cern.ch>
Date: Mon, 05 Jun 2000 22:10:21 +0000
Subject: Re: [Linux-ia64] Two IA-64 Linux bugs
Message-Id: <marc-linux-ia64-105590678205119@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205116@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205116@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 5 Jun 2000, Bill Nottingham wrote:

> Dan Pop (Dan.Pop@cern.ch) said: 
> > 
> > This is implemented by counting the lines starting with "CPU#" in
> > /proc/cpuinfo.  If the kernel guys change the format of that file, it
> > might break again.
> 
> Is there any reason why this reads /proc/cpuinfo and not /proc/stat?
> /proc/stat is at least consistent across architectures...

The right person to answer this question is the glibc maintainer, who
happens to be a colleague of yours :-)

Dan



