From: Chris McDermott <lcm@us.ibm.com>
Date: Mon, 10 Dec 2001 20:46:07 +0000
Subject: [Linux-ia64] Hard "hangs" with 2.4.16
Message-Id: <marc-linux-ia64-105590698805665@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Anybody else been seeing hangs with 2.4.16+ia64-1128.diff?  

I'm running on 4x Lions, some with B3's and some with C0's.  
The BIOS revision is 83B. I have seen the hang on at least 
4 of the systems. This is a hard hang, no kb interrupts, so 
kdb doesn't help. I don't have much to go on yet. The hangs 
occur in random places, sometimes at various places during 
boot and sometimes after the system has been up for a few 
minutes. I put an ITP (American Arium) on one of the failing 
systems and it didn't fail. Stayed up all night. I moved the 
ITP to another failing system and was able to catch 1 
occurrence of a "hang". I'm still trying to characterize this
hang to determine whether this is the same thing I am seeing 
on the other systems or just a hardware (configuration) problem.
What I saw from the ITP was that all of the processors had 
apparently reset (all of their IPs had returned to the reset 
vector, 0x80000000FFFFFF90 (I did have the ITP set to break on
reset, but it didn't trigger). Not much else to go on, since I
couldn't even dump any useful processor context.

Anyone else seeing this sort of odd behavior with 2.4.16 on 
Intel Lion SDVs?


Thanks,

Chris McDermott


