From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Fri, 25 Oct 2002 21:50:33 +0000
Subject: Re: [Linux-ia64] quick ia64 patch for 2.5.44 (UP only)
Message-Id: <marc-linux-ia64-105590709805252@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805243@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805243@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Thu, 24 Oct 2002 22:35:37 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> A quick patch that gets 2.5.44 (mostly) working on ia64 is now at
> ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in file:
> 
> 	linux-2.5.44-ia64-021024.diff.gz
> 
> With this patch, the kernel should work on Itanium 1, Itanium 2, and
> the Ski simulator, PROVIDED you use the "nosmp" option with SMP
> kernels.  Without "nosmp", the kernel crashes when starting up the
> application processors.  It appears that the crash is caused by
> something calling a NULL function pointer.

I found that tasklet_hi_action() seemed to call NULL pointer.
So I tried to put following code (I guess this is wrong fix)
into the function;

	if (t->func = NULL) {
		tasklet_unlock(t);
		continue;
	}

And the system initialization moved on, but it hung at INIT execution.
Anyway, I feel this problem might be related to the timer change.

http://marc.theaimsgroup.com/?l=linux-kernel&m3393743102152&w=2

Thanks,
Kimi

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


