From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Sun, 16 Feb 2003 11:28:28 +0000
Subject: Re: [Linux-ia64] How linux support ccNUMA machine?
Message-Id: <marc-linux-ia64-105590709805861@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805854@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805854@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2003-02-14 at 16:25, Barry Wu wrote:
> Hi, all, I am new to ccNUMA machine. I ask Mr. John about linux on
> SGI Altix 3000. Because he is not responsible for Altix prom,
> he could not give me any information about ccNUMA firmware that
> linux should depend on. Besides, he give me a lot of information
> about linux kernel. I do not know whether it is linux or firmware
> complete ccNUMA initialization. Because in Altix, it can support

I parse your question as: is the Linux kernel on the Altix 3000 aware of
ccNUMA or is this something that gets dealt in firmware?

If this was idneed your question ;-) then the answer is that although
you could build hardware/firmaware that will let you run non ccNUMA
aware operating system on ccNUMA operating system your perfomance  will
most likely be very lousy if the scheudler, for example, will not be
aware of the different memory spaces ansd the cost of accessing them
that is associated with a ccNUMA system. Therefore, the Linux kernel is
aware and manages the ccNUMA aspects of the system. Of course, it does
so via the PROM functions in firmware (PAL/SAL in IA64 speak. I think
:-)

> 64 cpus, but every 4 cpus is a C-brick. I think every C-brick has
> a prom. Therefore, it is under firmware complete 64 cpus initialization 
> or linux kernel complete. 

Again, I'm not sure I understood the question. The Linux kernel gets run
and initalized on each of the CPUs. Does this answer the question?

> Another question is for Itainum2, the system is boot from 4G-16MB address 
> space, if this ROM address can be replace with RAM address when system
> startup? Otherwise there will be many physical address holes in the system.
> Am I right?

I am not sure I understand the question. Linux has support for non
contingious memory, if that helps.

Gilad.
-- 
Gilad Ben-Yossef <gilad@benyossef.com>
http://benyossef.com

 "A 24-year-old South Korean man died after playing computer
  games nonstop for 86 hours, police said."

  http://www.smh.com.au/articles/2002/10/10/1034061260831.html


