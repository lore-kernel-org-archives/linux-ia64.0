From: Umut Aymakoglu <umuta@us.ibm.com>
Date: Thu, 21 Aug 2003 00:05:10 +0000
Subject: Re: libunwind
Message-Id: <marc-linux-ia64-106142441826443@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106141788020789@msgid-missing>
In-Reply-To: <marc-linux-ia64-106141788020789@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org





I need to put stack tracing into my program. To use the libunwinding , i
need to link with the library which will cause problems for the customers
who do not have the libunwind library.

thanks,
Umut


                                                                                                                               
                      David Mosberger                                                                                          
                      <davidm@napali.hp        To:       Umut Aymakoglu/Menlo Park/IBM@IBMUS                                   
                      l.hp.com>                cc:       linux-ia64@vger.kernel.org                                            
                                               Subject:  Re: libunwind                                                         
                      08/20/2003 04:52                                                                                         
                      PM                                                                                                       
                      Please respond to                                                                                        
                      davidm                                                                                                   
                                                                                                                               
                                                                                                                               




>>>>> On Wed, 20 Aug 2003 15:13:13 -0700, Umut Aymakoglu <umuta@us.ibm.com>
said:

  Umut> Are there any other alternatives for unwinding the stack on
Linux-ia64
  Umut> other than the libunwind API ?

Exactly what are you looking for?  Or put differently, what's wrong with
libunwind?

             --david



