From: "Grover, Andrew" <andrew.grover@intel.com>
Date: Tue, 13 Nov 2001 19:20:07 +0000
Subject: RE: [Linux-ia64] kacpidpc process takes 100% of CPU
Message-Id: <marc-linux-ia64-105590698805497@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805494@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805494@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ACPI interpreter starts threads to run control methods, and these are
labeled kacpidpc. When nothing is wrong, these are short-lived, and then
terminate.

Can you please use kdb, break in, and get a stack trace to find out where
we're stuck?

Thanks -- Regards -- Andy

> -----Original Message-----
> From: Paris, DavidX [mailto:davidx.paris@intel.com]
> Sent: Tuesday, November 13, 2001 9:44 AM
> To: 'linux-ia64@linuxia64.org'
> Subject: [Linux-ia64] kacpidpc process takes 100% of CPU
> 
> 
> I've just built 2.4.13 and 2.4.14 with and without the KDB 
> patch and in all
> cases when the system comes up there is a kacpidpc process 
> (PID 10) taking
> 100% of one of the cpus (changes which CPU it's on every 
> boot). The system
> is a 4 processor Lion (733 Mhz B3) with 1 gig of ram. This 
> process isn't
> even running when I build the same kernels on a BigSpur. I've 
> even tried
> copying over the very kernel that works fine on the BigSpur, 
> but when I boot
> it on the Lion I get this kacpidpc process. Naturally the 
> process ignores my
> 'kill -9's. I've tried booting the kernel on single proc 
> Lions (733 C0s),
> but the kernel won't even boot on those systems (hangs right 
> after it loads
> the SCSI driver is begins looking for devices). Does anyone 
> have any idea
> why this kacpidpc process is hogging one of the CPUs, and how 
> I go about
> getting rid of it? Unlike in the IA32 kernels, it doesn't 
> look like you can
> turn off ACPI in the IA64 kernel. Thanks,
> 
> David
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

