From: Christoph Rohland <cr@sap.com>
Date: Wed, 24 May 2000 18:32:32 +0000
Subject: Re: [Linux-ia64] Shared memory
Message-Id: <marc-linux-ia64-105590678205107@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205096@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205096@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ronen,

roneng@ca.ibm.com writes:
> Has anyone had a problem using the shmctl function to change the access
> mode of a shared memory
> block?
> 
> What I am doing is allocating shared memory using mode 666, and writing to
> it, then I use shmctl to change its
> mode to 600, switch to another userid using su, and try and read from the
> shared memory block. on ia32 linux
> I get an permission denied error, on ia64 with the latest turbolinux kernel
> and glibc i can read from that memory
> block.

That's an arch independent bug in the shm code. I will try to make a
fix beginning next week.

Thanks for spotting this,
                		Christoph

-- 


