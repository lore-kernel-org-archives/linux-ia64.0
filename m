From: Jun Nakajima <jun@sco.com>
Date: Tue, 17 Oct 2000 20:34:04 +0000
Subject: Re: [Linux-ia64] uni-processor kernel on SMP machine
Message-Id: <marc-linux-ia64-105590678205581@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205576@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205576@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Both UP and SMP kernels (2.4.0-test9) work fine on at least two 4-way
Lions (A2-stepping CPUs each with latest and a bit old firmware) at our
site. Can you be more specific about the problem you are seeing?

Pat O'Rourke wrote:
> 
> I attempted to boot a 2.4.0-test9 kernel compiled without SMP support
> on an MP Lion, but it would not boot.  I did the same experiemnt with
> older kernels and it appears this broke between test7 and test8.  Has
> anyone else noticed this?  Is there a work around / solution?
> 
> I noticed the problem on both a 2-way lion w/ B1 cpus and a 4-way lion
> with A2 cpus.
> 
> Thanks,
> 
> Pat
> 

-- 
Jun U Nakajima
Core OS Development
SCO/Murray Hill, NJ
Email: jun@sco.com, Phone: 908-790-2352 Fax: 908-790-2426

