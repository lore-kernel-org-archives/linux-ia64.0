From: Matt_Domsch@Dell.com
Date: Tue, 23 Apr 2002 21:07:53 +0000
Subject: RE: [Linux-ia64] running X with 2.4.18 kernel
Message-Id: <marc-linux-ia64-105590701905500@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905497@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905497@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Anybody running X with a 2.4.18 (either 0226 or 0410 ia64 
> patch) kernel? 
> I discovered a couple of weeks ago that it didn't work, at least with 
> the kernels I'm building. 

See the release notes for the first 2.4.18 patch that David made.  He
included a program to allow executable stack for certain apps (like X),
while keeping it non-executable by default.  X needs to have an executable
stack for scanpci to work.  After running David's program, it works fine for
me.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001!

