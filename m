From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 02 Jun 2004 07:14:22 +0000
Subject: Re: Real time clock on ia64 platforms
Message-Id: <20040602071422.GG10027@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40BC3558.7040606@hob.de>
In-Reply-To: <40BC3558.7040606@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christian,

> >>Dallas devices on PC boards.
> >>
> >>   
> >>
> >I am sorry but I don't know that device. What functionality of that device
> >is of interest to you?
> >
> It is just getting an absolute time without any calls to firmware or linux.
> 
at least on UP, can't you use a combination of gettimeofday() once and then use
ar.itc (equivalent of TSC) to make the appropriate adjustments. Also note
that on 2.6 with the right version of glibc, gettimeofday() is extremely fast.

-- 
-Stephane
