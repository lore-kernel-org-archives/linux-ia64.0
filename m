From: Bill Nottingham <notting@redhat.com>
Date: Mon, 05 Jun 2000 20:58:14 +0000
Subject: Re: [Linux-ia64] Two IA-64 Linux bugs
Message-Id: <marc-linux-ia64-105590678205118@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205116@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205116@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dan Pop (Dan.Pop@cern.ch) said: 
> I've fixed that in the "official" glibc tree one week ago.  It's been
> fixed in HJ's tree a few weeks ago (but I don't know how he did it).
> 
> This is implemented by counting the lines starting with "CPU#" in
> /proc/cpuinfo.  If the kernel guys change the format of that file, it
> might break again.

Is there any reason why this reads /proc/cpuinfo and not /proc/stat?
/proc/stat is at least consistent across architectures...

Bill


