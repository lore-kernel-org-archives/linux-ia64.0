From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 16:29:55 +0000
Subject: Re: [Linux-ia64] IA-32 emulation patch: ipc_perm32.patch
Message-Id: <marc-linux-ia64-105590723706077@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706000@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706000@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 22 May 2003 7:56 pm, Arun Sharma wrote:
> In the absence of the patch, this system call fails:
> 
> shmctl(shmid, IPC_STAT, &shmid_ds) 
> 
> The patch corrects the definition of the ipc_perm32 structure.

I applied this for 2.4.

