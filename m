From: Matt_Domsch@Dell.com
Date: Tue, 17 Oct 2000 22:02:42 +0000
Subject: Re: [Linux-ia64] qla1280 SCSI controller problems?
Message-Id: <marc-linux-ia64-105590678205583@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Running kernel 2.4.0-test9 + the -test9 IA-64 patch + the buglet patch +
modutils 2.3.18, I no longer see the lockups waiting on spinlocks that I was
seeing.  (Cross my fingers, and let it run overnight...)

Thanks,
Matt


-----Original Message-----
From: Domsch, Matt 
Sent: Monday, October 16, 2000 8:23 PM
To: 'Uros Prestor'; Broadfoot, KenX
Cc: ia64-dist@turbolinux.com
Subject: RE: [ia64-dist] Re: [Linux-ia64] qla1280 SCSI controller
problems?


"Broadfoot, KenX" wrote:

> Has anyone on this list seen the Lion lockup ( but not "crash" ) were
> seemingly the SCSI hard drive becomes unaccessable?
> The machine then requires a hard restart.
>
> I have ONLY seen this in kernel 2.4.0-test8 and 2.4.0-test9.
>
> I see typically when trying to insert a module or running a command like:
du

