From: Chris McDermott <lcm@us.ibm.com>
Date: Mon, 10 Dec 2001 22:49:45 +0000
Subject: Re: [Linux-ia64] Hard "hangs" with 2.4.16
Message-Id: <marc-linux-ia64-105590698805670@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805665@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805665@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack,

Looks like my problem is something else. This patch didn't
correct the problem.

Thanks,

Chris

On Mon, Dec 10, 2001 at 15:06 -0600, Jack Steiner wrote: 
> > 
> > Anybody else been seeing hangs with 2.4.16+ia64-1128.diff?  
> > 
> > I'm running on 4x Lions, some with B3's and some with C0's.  
> > The BIOS revision is 83B. I have seen the hang on at least 
> > 4 of the systems. This is a hard hang, no kb interrupts, so 
> > kdb doesn't help. I don't have much to go on yet. The hangs 
> > occur in random places, sometimes at various places during 
> > boot and sometimes after the system has been up for a few 
> > minutes. I put an ITP (American Arium) on one of the failing 
> > systems and it didn't fail. Stayed up all night. I moved the 
> > ITP to another failing system and was able to catch 1 
> > occurrence of a "hang". I'm still trying to characterize this
> > hang to determine whether this is the same thing I am seeing 
> > on the other systems or just a hardware (configuration) problem.
> > What I saw from the ITP was that all of the processors had 
> > apparently reset (all of their IPs had returned to the reset 
> > vector, 0x80000000FFFFFF90 (I did have the ITP set to break on
> > reset, but it didn't trigger). Not much else to go on, since I
> > couldn't even dump any useful processor context.
> 
> We saw the same symptom & tracked it down to a bug in the
> write_unlock() macro. The result was a memory-ordering problem
> that caused the "unlock" of the tasklist_lock to be made
> globally visible before the "store's" to the link fields were
> visible. The result was a closed loop in the tasklist links.
> 
> 
> Try  adding a barrier operation BEFORE the clear_bit.
> 
> 	OLD 
> 		#define write_unlock(x) ({clear_bit(31, (x)); mb();})
> 
> 	NEW
> 		#define write_unlock(x) ({smp_mb__before_clear_bit(); clear_bit(31, (x));})
> 
> 	
> This has been fixed in a later version of the IA64 patch.
> 
> 
> 
> > 
> > Anyone else seeing this sort of odd behavior with 2.4.16 on 
> > Intel Lion SDVs?
> > 
> > 
> > Thanks,
> > 
> > Chris McDermott
> > 
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> > 
> 
> 
> -- 
> Thanks
> 
> Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

