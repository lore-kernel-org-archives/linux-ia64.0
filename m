From: Chandra Kapate <cs_kapate@yahoo.com>
Date: Mon, 31 Mar 2003 04:33:07 +0000
Subject: Re: [Linux-ia64] 32bit syscall numbers
Message-Id: <marc-linux-ia64-105590723705361@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705359@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705359@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

THanks for clarifying Don.
Yes, there is no need for the list.....

Regards,
Chandra
--- n0ano@n0ano.com wrote:
> Chandra-
> 
> Why do you care?  The table in
> `arch/ia64/ia32/entry.S' is the only
> place in the kernel where the syscall numbers are
> needed and that
> information is embedded in the table, there's no
> need for a separate
> list.
> 
> On Fri, Mar 28, 2003 at 12:21:19PM -0800, Chandra
> Kapate wrote:
> > Hi,
> > 
> > How do I find the 32 bit syscall numbers?
> > I don't see any defines for, say __NR_ia32_chdir
> in 
> > any of the include files.
> > One can look at the arch/ia64/ia32/entry.S file
> and
> > deduce the numbers. But, is there any easy way?
> > I see asm-x86_64/ia32_unistd.h file which contains
> > the 32 bit syscall numbers.  But, I don't see the
> > corresponding file for ia64. 
> > 
> > I am running RedHat AS 2.1 on Itanium-2 box.
> > 
> > Thanks,
> > 
> > Chandra 
> > 
> > __________________________________________________
> > Do you Yahoo!?
> > Yahoo! Platinum - Watch CBS' NCAA March Madness,
> live on your desktop!
> > http://platinum.yahoo.com
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> >
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> -- 
> Don Dugger
> "Censeo Toto nos in Kansa esse decisse." - D. Gale
> n0ano@n0ano.com
> Ph: 303/447-2201


__________________________________________________
Do you Yahoo!?
Yahoo! Platinum - Watch CBS' NCAA March Madness, live on your desktop!
http://platinum.yahoo.com

