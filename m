From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 14 Feb 2003 20:11:33 +0000
Subject: Re: [Linux-ia64] Preempt problems
Message-Id: <marc-linux-ia64-105590709805857@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805801@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805801@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ray,

On Fri, Feb 14, 2003 at 02:05:53PM -0600, Ray Bryant wrote:
> 
> Does the deadlock you describe here look at all like the bug report that
> Jack Steiner has submitted for our Altix kernel?
> (We're using the O(1) scheduler and pfmon.)  (It certainly sound
> similar.) Details attached.
> 
> Is anyone working this issue that you know of?
> 
This problem was reported to me by Intel and others. It was affecting 
the 2.5 kernel only. However given that RHAS 2.1 is also using the
O(1) scheduler, I had to fix it in 2.4.18/RHAS. I don't exactly
know which kernel you are using at SGI. Note that the fix has been
propagated to 2.5.60 as well. I can provide the patch to you but
note that it also includes updates to perfmon to bring it closer
to what we have in 2.4.20. My  goal is to minimize the number of 
variations out there ;->


-- 
-Stephane

