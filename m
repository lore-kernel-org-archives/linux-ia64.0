From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Fri, 06 Oct 2000 17:13:16 +0000
Subject: Re: [Linux-ia64] Taking a dump while kernel panic
Message-Id: <marc-linux-ia64-105590678205553@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205552@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205552@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I'm looking for something to take a dump when system panic.
> I've found the patch from SGI to do that. But I'm asking if
> there is something to take a dump in the IA64 project ?

We (Mission Critical Linux) have a kernel patch which creates a
core dump on panic and also a tool (crash) which can be used to
analyze the resulting dump.  We're in the process of porting the
core dump patch to ia64; the crash tool has been ported to ia64
already.

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com



