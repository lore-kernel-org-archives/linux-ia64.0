From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 18 Apr 2001 06:21:03 +0000
Subject: Re: [Linux-ia64] One other question
Message-Id: <marc-linux-ia64-105590693005420@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005419@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005419@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
On Tue, Apr 17, 2001 at 10:11:19PM -0700, Weihaw CHUANG wrote:
> In regards to my previous email.  
> 
> What I'm really trying to get at is, is there a method to single step
> instructions with user level interrupts?
> 

I believe you can simply do this using the ptrace() system call and
giving it the PTRACE_SINGLESTEP command. Look at arch/ia64/kernel/ptrace.c
for more details.

-- 
-Stephane

