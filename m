From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Mon, 21 Oct 2002 16:42:17 +0000
Subject: RE: [Linux-ia64] Kernel Shared Memory Max (shmmax)
Message-Id: <marc-linux-ia64-105590709805202@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905286@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

         .....


> Sorry, but obviously I'm still confused here.  Is there a max 
> of 8GB or any 
> other value that I cannot exceed on IA-64 systems?
> 

There is no limit of 8G on shared memory segments from IA-64 arch.  As long
as you are keeping the values shm* parameters large in kernel, you should be
able to go to few TB range.  If you have bigger memory machine then go ahead
and bump up the values of these shm parameters.  (Though I think ipcs is
probably still broken and will not print the correct values), but you should
actually be able to use these big segments.

rohit

