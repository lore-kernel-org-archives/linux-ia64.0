From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 16:15:47 +0000
Subject: Re: [Linux-ia64] IA-32 emulation patch: msgctl.patch
Message-Id: <marc-linux-ia64-105590723706073@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705994@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705994@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 22 May 2003 7:35 pm, Arun Sharma wrote:
> Arun Sharma <arun.sharma@intel.com> writes:
> 
> > IA-32 programs executing:
> > 
> > msgctl(id, IPC_SET, &buf)
> > 
> > currently fail with EPERM due to this bug. 

I applied this for 2.4.  Thanks!

