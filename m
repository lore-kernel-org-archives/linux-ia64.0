From: Ray Bryant <raybry@engr.sgi.com>
Date: Fri, 14 Feb 2003 21:04:52 +0000
Subject: Re: [Linux-ia64] Preempt problems
Message-Id: <marc-linux-ia64-105590709805858@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805801@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805801@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane,

We're using a 2.4.19 kernel with a number of patches and SGI fixes, and
some backports from 2.5, as well as our machine 
specific stuff.  A more complete description of what we run is:

--2.4.19 from www.kernel.org
--IA64 patch
--Atlas patches including discontinguous memory support, VM support
--O(1) scheduler -- including some fixes for large CPU counts, etc
--SGI machine specific H/W support
--SGI patches and fixes for bugs and scalability
--PAGG
--CSA (Comprehensive System Accounting)
--XSCSI (our version of SCSI support from IRIX -- this is a
module/closed source)

Of interest for this discussion is the O(1) scheduler and perfmon.

If you could send me your patch, I will take a look at it and see what
applies.

We will eventually be going to RHAS, but at the moment we are running a
"free-bytes" clone of RH 7.2.

I understand exactly why you are trying to keep the number of variations
small.

Thanks,

Stephane Eranian wrote:
> 
> Ray,
> 
> On Fri, Feb 14, 2003 at 02:05:53PM -0600, Ray Bryant wrote:
> >
> > Does the deadlock you describe here look at all like the bug report that
> > Jack Steiner has submitted for our Altix kernel?
> > (We're using the O(1) scheduler and pfmon.)  (It certainly sound
> > similar.) Details attached.
> >
> > Is anyone working this issue that you know of?
> >
> This problem was reported to me by Intel and others. It was affecting
> the 2.5 kernel only. However given that RHAS 2.1 is also using the
> O(1) scheduler, I had to fix it in 2.4.18/RHAS. I don't exactly
> know which kernel you are using at SGI. Note that the fix has been
> propagated to 2.5.60 as well. I can provide the patch to you but
> note that it also includes updates to perfmon to bring it closer
> to what we have in 2.4.20. My  goal is to minimize the number of
> variations out there ;->
> 
> --
> -Stephane

-- 
Best Regards,
Ray
-----------------------------------------------
                  Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------

