From: "Niels Christiansen" <nchr@us.ibm.com>
Date: Wed, 30 Jan 2002 07:27:46 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805958@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oops, forgot to mention these two lines.  They represent trace
overhead because my kernel is instrumented to trace all function
entry and exit points.  All it means is that 9.92 + 9.33 percent
of the time spent in your process is trace overhead.  It should
not skew the relative weight of the other profile data.

   4696    9.92    2.38  kernel __cyg_profile_func_enter []
   4416    9.33    2.24  kernel __cyg_profile_func_exit []

I also checked lock stats.  You wait for and hold locks less
than 150 msecs.  What I can't explain is why the system is 60%
busy (although I know that ACPI handlers keep one processor
100% busy).

-----------------------------------------------------------------
    LTC Whydle Version 1.0.3 *** PROCESSOR TIME DISTRIBUTION
-----------------------------------------------------------------

             Total   TID-0   Other  non-IRQ
CPU  Idle %  Busy %  IRQ %   IRQ %   Busy %
--- ------- ------- ------- ------- -------
  0  62.649  37.351   0.000   0.000  37.351
  1  43.502  56.498   0.000   0.000  56.498
  2   0.000 100.000   0.000   0.000 100.000
  3  55.906  44.094   0.000   0.000  44.094
    ------- ------- ------- ------- -------
     40.514  59.486   0.000   0.000  59.486

... Niels


