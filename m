From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Tue, 10 Feb 2004 23:55:03 +0000
Subject: Re: [patch] 2.6.2-rc2 Remove compile warnings from timer.o
Message-Id: <20040210235503.GB15247@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040205061136.GD25002@cse.unsw.EDU.AU>
In-Reply-To: <20040205061136.GD25002@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David

On Tue, 10 Feb 2004, David Mosberger wrote:


> 
>   Darren> -#  define HZ	  32
>   Darren> +#  define HZ	  96
> 
> Doesn't strike me as the correct fix: looking at timex.h, clearly HZ
> values as low as 12Hz are supposed to be supported.  Perhaps a better
> fix would be to change timer.c to verify that
> SHIFT_SCALE<=SHIFT_USEC+SHIFT_HZ before attempting to do the shifting
> (via a CPP #if, of course).
> 
> Also, I'm a bit reluctant to increase the HZ value for the simulator,
> because too large a value will cause the simulated kernel to fail to
> make forward progress on slow host machines.

I thouht that this might be the case, though the fisrt attempt modified
the smallest amount of source.

> 	--david

Hope the attached is suitable.

Darren

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="timer.c.patch"

--- linux-2.6.2-rc2.orig/kernel/timer.c	2004-02-11 10:45:02.000000000 +1100
+++ linux-2.6.2-rc2/kernel/timer.c	2004-02-11 10:01:26.000000000 +1100
@@ -584,12 +584,22 @@ static void second_overflow(void)
 			 STA_PPSWANDER | STA_PPSERROR);
     }
     ltemp = time_freq + pps_freq;
+    
+#if (SHIFT_SCALE <= (SHIFT_USEC + SHIFT_HZ))
     if (ltemp < 0)
 	time_adj -= -ltemp >>
 	    (SHIFT_USEC + SHIFT_HZ - SHIFT_SCALE);
     else
 	time_adj += ltemp >>
 	    (SHIFT_USEC + SHIFT_HZ - SHIFT_SCALE);
+	    
+#else	/* (SHIFT_SCALE > (SHIFT_USEC + SHIFT_HZ)) */
+    if (ltemp < 0)
+	time_adj -= -ltemp >> SHIFT_SCALE;
+    else
+	time_adj += ltemp >> SHIFT_SCALE;
+	    
+#endif /* (SHIFT_SCALE > (SHIFT_USEC + SHIFT_HZ)) */
 
 #if HZ == 100
     /* Compensate for (HZ==100) != (1 << SHIFT_HZ).

--y0ulUmNC+osPPQO6--
