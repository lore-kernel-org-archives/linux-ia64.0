From: Jes Sorensen <jes@sunsite.dk>
Date: Thu, 15 Nov 2001 21:01:12 +0000
Subject: Re: Qlogic scsi driver (was Re: [Linux-ia64] kacpidpc process takes 100% of CPU)
Message-Id: <marc-linux-ia64-105590698805520@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805500@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805500@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Randall" = Randall G Chan <chanr@us.ibm.com> writes:

Randall> I've actually noticed this too on both kernels 2.4.13 &
Randall> 2.4.14.  I have not yet been able to figure out what's wrong
Randall> with it.  I have a kernel that works fine on a 4-way C0 Lion,
Randall> BIOS 99, but when I stick it on a single C0 BIOS 99, the
Randall> kernel hangs in the above spot (prints out copyright info and
Randall> driver version, then just hangs when it's <seemingly>
Randall> scanning the scsi bus).  Anyone else notice this or have a
Randall> solution?

Which version of the SCSI driver are you using? I am maintaining a
patch at http://www.wildopensource.com/~jes/linux/ which contains a
large number of bug fixes and cleanups.

However I don't have access to a Lion so I can't reproduce this.

Cheers
Jes

