From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 16:18:37 +0000
Subject: Re: [Linux-ia64] IA-32 emulation patch: shmctl.patch
Message-Id: <marc-linux-ia64-105590723706075@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705997@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705997@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 22 May 2003 7:46 pm, Arun Sharma wrote:
> This one is similar to msgctl. We should be calling sys_shmctl with
> struct shmid64_ds. 
> 
> In the absence of this patch:
> 
> shmctl(shmid, IPC_SET, &shmid_ds)
> 
> will fail.

I applied this for 2.4.

