From: "Sourav Sen" <souravs@india.hp.com>
Date: Tue, 03 Aug 2004 13:57:00 +0000
Subject: RE: [ia64 R&D] CONFIG_IA64_MCA
Message-Id: <00f001c47960$131e7140$39624c0f@asiapacific.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
In-Reply-To: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry to dig thigs up from the past, but when I apply
this against 2.6.6 and pass the nomca flag, I get MCA in 
the boot path on sx1000 based systems of HP. 

Thanks
Sourav
HP-STS, Bangalore
+91-80-2205-1897


+ -----Original Message-----
+ From: linux-ia64-owner@vger.kernel.org
+ [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Chen, Kenneth W
+ Sent: Saturday, May 08, 2004 2:58 AM
+ To: 'Jesse Barnes'; CURRY,JOHN W (HP-Cupertino,ex1)
+ Cc: Luck, Tony; linux-ia64@vger.kernel.org
+ Subject: RE: [ia64 R&D] CONFIG_IA64_MCA
+ 
+ 
+ >>>> Jesse Barnes wrote on Friday, May 07, 2004 12:57 PM
+ >
+ > On Tuesday, May 4, 2004 7:51 pm, CURRY,JOHN W 
+ (HP-Cupertino,ex1) wrote:
+ > > Well, once it's working I think this will be okay for our team.
+ >
+ > Any chance you could test the patch for me?  Anyone else 
+ have hw they
+ > could try it on?
+ 
+ Is there another patch or this is the latest one?
+ http://www.gelato.unsw.edu.au/linux-ia64/0405/9514.html
+ 
+ If that's the latest one, then it won't boot on any machine with nomca
+ parameter because once match found, it stuck in the for loop 
+ and memcmp
+ endlessly, cp never gets incremented :-(
+ 
+ How about this one:
+ 
+ diff -Nur linux-2.6.6-rc3/arch/ia64/kernel/setup.c 
+ linux-2.6.6-rc3.ken/arch/ia64/kernel/setup.c
+ --- linux-2.6.6-rc3/arch/ia64/kernel/setup.c	2004-04-27 
+ 18:35:09.000000000 -0700
+ +++ linux-2.6.6-rc3.ken/arch/ia64/kernel/setup.c	
+ 2004-05-07 14:22:18.000000000 -0700
+ @@ -360,8 +360,9 @@
+  # endif
+  #endif
+ 
+ -	/* enable IA-64 Machine Check Abort Handling */
+ -	ia64_mca_init();
+ +	/* enable IA-64 Machine Check Abort Handling unless disabled */
+ +	if (!strstr(saved_command_line, "nomca "))
+ +		ia64_mca_init();
+ 
+  	platform_setup(cmdline_p);
+  	paging_init();
+ 
+ 
+ -
+ To unsubscribe from this list: send the line "unsubscribe 
+ linux-ia64" in
+ the body of a message to majordomo@vger.kernel.org
+ More majordomo info at  http://vger.kernel.org/majordomo-info.html
+ 
