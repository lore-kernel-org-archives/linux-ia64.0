From: "Aneesh Kumar K.V" <aneesh.kumar@digital.com>
Date: Thu, 18 Sep 2003 05:48:38 +0000
Subject: Re: [PATCH] 2.4 force_successful_syscall()
Message-Id: <marc-linux-ia64-106386411811299@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106323341214232@msgid-missing>
In-Reply-To: <marc-linux-ia64-106323341214232@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-09-18 at 11:12, Kumar, Aneesh wrote:
> On Thu, 2003-09-18 at 01:30, Marcelo Tosatti wrote:
> > On Wed, 10 Sep 2003, Bjorn Helgaas wrote:
> > 
> > > Here's a 2.4 backport of this change to 2.5:
> > > 
> > >
> >
> http://linux.bkbits.net:8080/linux-2.5/cset@1.1046.238.7?nav=index.html
> > > 
> > > Alpha, ppc, and sparc64 define force_successful_syscall_return() in
> > 2.5,
> > > but since it's not obvious to me how to do it correctly in 2.4, I
> left
> > > them unchanged.
> > 
> > Whats the reasoning behing this patch?
> 
> IIRC those changes were added to 2.5 by David. Architecture like Ia64
> and Alpha support error return via a different register set ( $19 for
> Alpha ). But syscalls like ptrace can have negative return value for
> successful returns. So in that particular case $19 is forced to be zero
> to indicate it is a successful return. IIUC
> force_successful_syscall_return  is a wrapper around doing that. On
> alpha actually r0 in the stack (regs.r0 ) is made zero which is  read in
> entry.S and put in $19. 


For IA64 I guess it is r10 and regs.r8. May be other can correct me if i
am wrong. 

-aneesh 


