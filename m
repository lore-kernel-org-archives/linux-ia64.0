From: "Randall G Chan/Fremont/IBM" <chanr@us.ibm.com>
Date: Fri, 22 Sep 2000 00:45:13 +0000
Subject: Re: [Linux-ia64] unregister_rebbot_notifier()
Message-Id: <marc-linux-ia64-105590678205515@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205511@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205511@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I didn't test it extensively, but I inserted a couple of modules and
everything seem to be okay.  And my problem was that I did have a mismatch
btwn modutils and the kernel.

Thanks,
Randy Chan
chanr@us.ibm.com

--------------------------------------------------------------------------


                                                                                                                                
                    Keith Owens                                                                                                 
                    <kaos@ocs.com.au>           To:     linux-ia64@linuxia64.org                                                
                    Sent by:                    cc:     Randall G Chan/Fremont/IBM@IBMUS                                        
                    linux-ia64-admin@lin        Subject:     Re: [Linux-ia64] unregister_rebbot_notifier()                      
                    uxia64.org                                                                                                  
                                                                                                                                
                                                                                                                                
                    09/21/00 04:44 PM                                                                                           
                                                                                                                                
                                                                                                                                




On Thu, 21 Sep 2000 14:03:51 -0700,
"Randall G Chan/Fremont/IBM" <chanr@us.ibm.com> wrote:
>Also, I can't seem to get this module to load on 2.4.0-test8.  This system
>just seems to hang after trying to insert the module.  I've seen this
>happen on the same two machines listed above.  Are there any known
problems
>in test8 in relation to module loading?

Please try modutils 2.3.16 plus the patch at
ftp://ftp.ocs.com.au/private/modutils-2.3.16-patch-1, let me know if it
works so I can release it as modutils 2.3.17.


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64



