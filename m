From: Paul Jackson <pj@sgi.com>
Date: Fri, 07 Nov 2003 02:06:28 +0000
Subject: Re: [DMESG] cpumask_t in action
Message-Id: <marc-linux-ia64-106817088009058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106807117402763@msgid-missing>
In-Reply-To: <marc-linux-ia64-106807117402763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The BogoMIPS is another which I would think could be eliminated unless
> it is significantly different from the boot cpu.  Maybe say greater
> than 10% different.

Or just show the min and max:

  BogoMIPS for 64 CPUs range from 2241.08 to 2298.56

If someone knows they have 32 CPUs at 1.1 GHz, and 32 CPUs at 1.3 GHz,
they don't need to see 32 of these listed as >10% out of spec.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
